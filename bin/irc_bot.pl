#!/usr/bin/perl

use strict;
use warnings;
use Carp qw/croak/;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use CollabIRCate::Config;
use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Bot;
use CollabIRCate::Bot::Users;

# use CollabIRCate::File qw/accept_file/;

use CollabIRCate::Logger;

my $bot = CollabIRCate::Bot->new();    # create a bot
my @periodics = $bot->register_periodics();            # figure out what we need to do periodically


my $config = CollabIRCate::Config->config;

my $HOST    = $config->{irc_bot_server_host} || croak "no server host";
my $PORT    = $config->{irc_bot_server_port} || croak "no server port";
my $BOTNICK = $config->{irc_bot_nickname}    || 'undefBOT';

use POE;
use POE::Component::IRC;
use POE::Component::IRC::Common qw/parse_user/;

my $logger = CollabIRCate::Logger->get('irc_bot');

# Create the component that will represent an IRC network.
$logger->info('creating irc component');
my ($irc) = POE::Component::IRC->spawn();

# Create the bot session.  The new() call specifies the events the bot
# knows about and the functions that will handle those events.
$logger->info('creating session');
POE::Session->create(
    inline_states => {
        _start          => \&bot_start,
        irc_001         => \&on_connect,
        irc_public      => \&on_public,
        irc_invite      => \&on_invite,
        irc_join        => \&on_join,
        irc_topic       => \&on_topic,
        irc_part        => \&on_part,
        irc_quit        => \&on_quit,
        irc_msg         => \&on_msg,
        irc_ctcp_action => \&on_ctcp_action,
        irc_353         => \&on_names,

        _default => \&unknown,

        irc_dcc_request => \&dcc_request,
        irc_dcc_get     => \&dcc_get,
        irc_dcc_done    => \&dcc_done,

        irc_whois => \&whois,
        irc_nick  => \&nick,

        #        check_tells    => \&check_tells,
        check_requests => \&check_requests,

        run_periodic => \&run_periodic,

        debug => \&debug,
    },
);

# The bot session has started.  Register this bot with the "magnet"
# IRC component.  Select a nickname.  Connect to a server.
sub bot_start {
    my $kernel  = $_[KERNEL];
    my $heap    = $_[HEAP];
    my $session = $_[SESSION];

    $logger->info('bot starting');

    $irc->yield( register => "all" );

    $irc->yield(
        connect => {
            Nick     => $BOTNICK,
            Username => 'peoplebot',
            Password => 'fishdontbreathe',
            Ircname  => 'POE::Component::IRC cookbook bot',
            Server   => $HOST,
            Port     => $PORT,

            #            Debug    => 1,
        }
    );
    $kernel->delay( check_tells    => 10 );
    $kernel->delay( check_requests => 10 );
    $kernel->delay( debug          => 5 );
}

# The bot has successfully connected to a server.
# Setup the periodic stuff.
sub on_connect {
    my $kernel  = $_[KERNEL];
    $logger->info('bot connected');
    $irc->yield( oper => '~peoplebot' => 'fishdontbreathe' );

    foreach (@periodics) {
        my ($delay, $sub) = @$_;
        $kernel->delay('run_periodic' => $delay, $sub, $delay);
    }
    
}

# The bot has received a public message.  Parse it for commands, and
# respond to interesting things.
sub on_public {
    my ( $kernel, $who, $where, $msg ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $channel = $where->[0];

    $logger->debug("bot saw public message '$msg'");

    my $ts   = scalar localtime;
    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    add_log( $user, $channel, 'log', $msg );

    if (   $msg =~ /^$BOTNICK,\s*(.*)/i
        || $msg =~ /^$BOTNICK\s+(.*)/i
        || $msg =~ /^${BOTNICK}:\s*(.*)/i
        || $msg =~ /^(.*)\s+${BOTNICK}\s*\?*$/i )
    {
        my $response = $bot->bot_addressed( $user, $channel, $1 );
        $response->emit($irc);
    }
    else {
        my $response = $bot->bot_heard( $user, $channel, $msg );
        $response->emit($irc);
    }

}

sub on_ctcp_action {
    my ( $kernel, $who, $where, $what ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    add_log( $user, $where->[0], 'action', $what );
}

# private msg
sub on_msg {
    my ( $kernel, $who, $what ) = @_[ KERNEL, ARG0, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    my $response = $bot->bot_addressed( $user, undef, $what );
    $response->emit($irc);
}

sub on_invite {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];

    $logger->info( 'bot invited to channel ' . $where );
    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    $irc->yield( join => $where );

}

sub on_join {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];

    $logger->debug("saw '$who' join '$where'");
    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    $user->add_channel($where);

    $logger->debug("issueing 'names' request");
    $irc->yield( 'names' => $where );

    my $channel = $where;

    add_log( $user, $channel, 'join', 'joined' );
}

sub on_topic {
    my ( $kernel, $who, $where, $topic ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    add_log( $user, $where, 'topic', $topic );
}

sub on_part {
    my ( $kernel, $who, $where, $why ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    $user->remove_channel($where);

    my $channel = $where;
    add_log( $user, $channel, 'part', $why );
}

sub on_quit {
    my ( $kernel, $who, $why ) = @_[ KERNEL, ARG0, ARG1 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    # tell the bot that a user quit
}

sub unknown {
    my ( $event, $args ) = @_[ ARG0 .. $#_ ];
    my @output = ("$event: ");

    for my $arg (@$args) {
        if ( ref $arg eq 'ARRAY' ) {
            push( @output, '[' . join( ' ,', @$arg ) . ']' );
        }
        else {
            push( @output, "'$arg'" );
        }
    }

    # interesting but verbose:
    # print join ' ', @output, "\n";
    return 0;
}

sub check_requests {
    my ($kernel) = @_[ KERNEL, ARG0 ];

}

sub dcc_request {
    my $heap = $_[HEAP];
    my ( $who, $type, $port, $cookie, $file, $size, $addr )
        = @_[ ARG0 .. $#_ ];

}

sub dcc_get {

    # for now we just ignore these, they are noise.
}

sub dcc_done {
    my $heap = $_[HEAP];
    my ( $nick, $filename, $size ) = @_[ ARG1, ARG4, ARG5 ];

    # filename is the request hash!
    my $hash = $filename;
    $hash =~ s/.*([0-9a-f]{32}).*/$1/g;

    # but the filename they really want is here
    my $requested_filename = $heap->{dcc}->{transfers}->{$hash};
    delete $heap->{dcc}->{transfers}->{$hash};

    my @ids;
    eval { @ids = accept_file( $filename, $hash, $requested_filename ); };

    # XXX
    die $@ if $@;

    # clean up tmp
    unlink $filename;

}

sub on_names {
    my $names = ( split /:/, $_[ARG1] )[1];

    $logger->debug("received 'names' request");

    # do a whois on each
    foreach my $nick ( split /\s+/, $names ) {
        $logger->debug("doing whois for '$nick'");

        # remove op symbols from nick and issue a whois
        $nick =~ s/^[^\w]//;
        $irc->yield( whois => $nick );
    }
}

sub whois {
    my $info = $_[ARG0];

    $logger->debug("received irc_whois with '$info'");

    return if ( !$info->{channels} );
    my @channels = @{ $info->{channels} };
    $logger->debug("there are channels: @channels");

    s/^@// foreach @channels;    # remove oper crap

    # get the bot user and this user objects
    my $botU = CollabIRCate::Bot::Users->from_nick($BOTNICK);
    my $user = CollabIRCate::Bot::Users->from_ircuser( $info->{nick},
        $info->{user}, $info->{host} );

    # only consider the channels that the bot is also on
    my %bot_channels = map { $_ => 1 } @{ $botU->channels() };

    foreach (@channels) {
        $user->add_channel($_) if ( $bot_channels{$_} );
    }
}

sub nick {
    my ( $changer, $newnick ) = @_[ ARG0, ARG1 ];
    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($changer) );
    $user->nick($newnick);
}

sub debug {
    my $kernel = $_[KERNEL];
    return;
    CollabIRCate::Bot::Users->dump();
    $kernel->delay( debug => 5 );
}

sub irc_bot_addressed {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    my $nick    = ( split /!/, $_[ARG0] )[0];
    my $channel = $_[ARG1]->[0];
    my $what    = $_[ARG2];

    print "$nick addressed me in channel $channel with the message '$what'\n";
}

sub run_periodic {
    my ( $kernel, $sub, $delay) = @_[ KERNEL, ARG0, ARG1 ];

    # run the coderef
    &$sub($irc);
    
    # reschedule
    $kernel->delay('run_periodic' => $delay, $sub, $delay);
}

# Run the bot until it is done.
$poe_kernel->run();
exit 0;
