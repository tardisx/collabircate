#!/usr/bin/perl

use strict;
use warnings;
use Carp qw/croak/;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;


use CollabIRCate::Config;
use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Bot qw/bot_heard bot_addressed/;
use CollabIRCate::Bot::Users;
# use CollabIRCate::File qw/accept_file/;

my $config = CollabIRCate::Config->config;

my $HOST    = $config->{irc_bot_server_host} || croak "no server host";
my $PORT    = $config->{irc_bot_server_port} || croak "no server port";
my $BOTNICK = $config->{irc_bot_nickname}    || 'undefBOT';


use POE;
use POE::Component::IRC;
use POE::Component::IRC::Common qw/parse_user/;
use POE::Component::IRC::Plugin::BotAddressed;

my $seen = {};

# Create the component that will represent an IRC network.
my ($irc) = POE::Component::IRC->spawn();

# Create the bot session.  The new() call specifies the events the bot
# knows about and the functions that will handle those events.
POE::Session->create(
    inline_states => {
        _start     => \&bot_start,
        irc_001    => \&on_connect,
        irc_public => \&on_public,
        irc_invite => \&on_invite,
        irc_join   => \&on_join,
        irc_topic  => \&on_topic,
        irc_part   => \&on_part,
        irc_quit   => \&on_quit,
        irc_msg    => \&on_msg,
        irc_ctcp_action    => \&on_ctcp_action,
        irc_353    => \&on_names,

        _default => \&unknown,

        irc_dcc_request => \&dcc_request,
        irc_dcc_get     => \&dcc_get,
        irc_dcc_done    => \&dcc_done,

        irc_whois => \&whois,
        irc_nick  => \&nick,

#        check_tells    => \&check_tells,
        check_requests => \&check_requests,

        debug => \&debug,
    },
);

# The bot session has started.  Register this bot with the "magnet"
# IRC component.  Select a nickname.  Connect to a server.
sub bot_start {
    my $kernel  = $_[KERNEL];
    my $heap    = $_[HEAP];
    my $session = $_[SESSION];

    $irc->yield( register => "all" );
    $irc->plugin_add( 'BotAddressed', POE::Component::IRC::Plugin::BotAddressed->new() );

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

# The bot has successfully connected to a server.  Join a channel.
sub on_connect {
    $irc->yield( oper => '~peoplebot' => 'fishdontbreathe' );

}

# The bot has received a public message.  Parse it for commands, and
# respond to interesting things.
sub on_public {
    my ( $kernel, $who, $where, $msg ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $channel = $where->[0];

    my $ts   = scalar localtime;
    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    add_log( $who, $channel, 'log', $msg );

    if (   $msg =~ /^$BOTNICK,\s*(.*)/i
        || $msg =~ /^$BOTNICK\s+(.*)/i
        || $msg =~ /^${BOTNICK}:\s*(.*)/i
        || $msg =~ /^(.*)\s+${BOTNICK}\s*\?*$/i )
        {
            my $response = bot_addressed($who, $channel, $1);
            $response->emit($irc);

            # and fake the log
            #        my $botwho = CollabIRCate::Bot::Users->new({irc_user => $BOTNICK});
            #        add_log( $botwho, $channel, 'log', $bot_says_pub );

    }
    else {
        my $response = bot_heard($who, $channel, $msg);
        $response->emit($irc);
    }

}

sub on_ctcp_action {
    my ( $kernel, $who, $where, $what ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    add_log( $who, $where->[0], 'action', $what );
}

# private msg
sub on_msg {
    my ( $kernel, $who, $what ) = @_[ KERNEL, ARG0, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    bot_addressed($who, undef, $what);
}

sub on_invite {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    $irc->yield( join => $where );

}

sub on_join {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    $user->add_channel($where);

    $irc->yield( 'names' => $where );

    my $channel = $where;
    $seen->{$channel}->{$who} = 1;

    add_log( $who, $channel, 'join', 'joined' );
    if ( $who =~ /justin|garner|nick|adam|ev|mwp/i ) {
        $irc->yield( 'mode' => $channel => '+o' => $who );
    }
}

sub on_topic {
    my ( $kernel, $who, $where, $topic ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    add_log( $who, $where, 'topic', $topic );
}

sub on_part {
    my ( $kernel, $who, $where, $why ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    $user->remove_channel($where);

    my $channel = $where;
    $seen->{$channel}->{$who} = 0;
    add_log( $who, $channel, 'part', $why );
}

sub on_quit {
    my ( $kernel, $who, $why ) = @_[ KERNEL, ARG0, ARG1 ];

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );

    # this is perhaps wrong in some edge cases?
    foreach my $channel ( keys %$seen ) {
        if ( $seen->{$channel}->{$who} ) {
            $seen->{$channel}->{$who} = 0;
            add_log( $who, $channel, 'quit', $why );
        }
    }
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

sub check_tells {
    my ($kernel) = @_[ KERNEL, ARG0, ARG1 ];
    my @tells = get_tells();
    foreach my $a_tell (@tells) {
        my ( $who, $msg, $time ) = @$a_tell;
        foreach my $channel ( keys %$seen ) {
            if ( $seen->{$channel}->{$who} ) {
                $irc->yield(
                    privmsg => $channel,
                    "someone told me to tell you '$msg', $who"
                );
                del_tell( $who, $msg, $time );
                last;
            }
        }
    }
    $kernel->delay( check_tells => 10 );
}

sub check_requests {
    my ($kernel) = @_[ KERNEL, ARG0 ];

}

=pod

    # check the database to see if we have any new requests that
    # have been uploaded
    my %requests_logged = ();
    my $files           = $schema->resultset('File')->search(
        { 'request.logged' => 'f', },
        { join             => { request => 'channel' } }
    );

    #                  { join      => { 'request' => 'file' },
    #                    '+select' => [ 'request.id' ],
    #                    '+as'     => [ 'request_id' ]
    #                }
    #              );

    while ( my $unlogged = $files->next ) {

        # we have a file for a channel
        my $channel = $unlogged->request->channel;
        if (! $channel) {
          warn "No channel ??";
          next;
        }
        my $channel_name = $channel->name;
        my $url 
            = 'http://' 
            . $config->{http_server_host}
            . (
            $config->{http_server_port}
            ? ':' . $config->{http_server_port}
            : ''
            )
            . $config->{http_server_path} . "file/"
            . $unlogged->id;
        my $filename = $unlogged->filename;
        $filename =~ s/.*\///;
        my $message
            = $filename . " has been uploaded, download it at " . $url;

        $irc->yield( privmsg => $channel, $message );

        # fake the log
        add_log( $BOTNICK, $channel, 'log', $message );
        $requests_logged{ $unlogged->request->id } = 1;
    }

    foreach ( keys %requests_logged ) {
        $schema->resultset('Request')->search( { id => $_ } )
            ->update( { logged => 't' } );
    }

    $kernel->delay( check_requests => 10 );
}

=cut

sub dcc_request {
    my $heap = $_[HEAP];
    my ( $who, $type, $port, $cookie, $file, $size, $addr )
        = @_[ ARG0 .. $#_ ];

}

=pod
    
    return if $type ne 'SEND';

    my $user = CollabIRCate::Bot::Users->from_ircuser( parse_user($who) );
    my $nick = $user->nick();

    # get the channel
    my $channel;
    unless ( $channel = $user->one_channel ) {
        my $message = "I don't know which channel to send your file. You are "
            . "not on any channels I know about, or more than one. Sorry.";
        $irc->yield( privmsg => $user->nick, $message );
        return;
    }

    # make a request
    my $chan
        = $schema->resultset('Channel')->search( { name => $channel } )->next;
    my $chan_id;
    $chan_id = $chan->id if ($chan);
    my $req
        = $schema->resultset('Request')->create( { channel_id => $chan_id } );

    # remember the filename they originally desired
    $heap->{dcc}->{transfers}->{ $req->hash } = $file;

    $irc->yield( dcc_accept => $cookie, "/tmp/" . $req->hash );
}

=cut

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

    # do a whois on each
    foreach my $nick ( split /\s+/, $names ) {

        # remove op symbols from nick and issue a whois
        $nick =~ s/^[^\w]//;
        $irc->yield( whois => $nick );
    }
}

sub whois {
    my $info = $_[ARG0];

    return if (! $info->{channels});
    my @channels = @{ $info->{channels} };

    s/^@// foreach @channels;    # remove oper crap

    # get the bot user and this user objects
    my $bot  = CollabIRCate::Bot::Users->from_nick($BOTNICK);
    my $user = CollabIRCate::Bot::Users->from_ircuser( $info->{nick},
        $info->{user}, $info->{host} );

    # only consider the channels that the bot is also on
    my %bot_channels = map { $_ => 1 } @{ $bot->channels() };

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
  my ($kernel, $heap) = @_[KERNEL, HEAP];
  my $nick = ( split /!/, $_[ARG0] )[0];
  my $channel = $_[ARG1]->[0];
  my $what = $_[ARG2];

  print "$nick addressed me in channel $channel with the message '$what'\n";
}

# Run the bot until it is done.
$poe_kernel->run();
exit 0;
