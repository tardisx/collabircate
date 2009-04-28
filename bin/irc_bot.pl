#!/usr/bin/perl

# A fairly simple example:
use strict;
use warnings;
use Carp qw/croak/;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use CollabIRCate::Config;
use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Bot qw/bot_request get_tells del_tell/;

my $config = CollabIRCate::Config->config();
my $schema = CollabIRCate::Config->schema();

my $HOST    = $config->{irc_bot_server_host} || croak "no server host";
my $PORT    = $config->{irc_bot_server_port} || croak "no server port";
my $BOTNICK = $config->{irc_bot_nickname}    || 'undefBOT';

use POE;
use POE::Component::IRC;
use POE::Component::IRC::Plugin::CycleEmpty;

my $seen = {};

# Create the component that will represent an IRC network.
my ($irc) = POE::Component::IRC->spawn();
$irc->plugin_add( 'CycleEmpty',
    POE::Component::IRC::Plugin::CycleEmpty->new() );

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
        _default   => \&unknown,

        check_tells    => \&check_tells,
        check_requests => \&check_requests,
    },
);

# The bot session has started.  Register this bot with the "magnet"
# IRC component.  Select a nickname.  Connect to a server.
sub bot_start {
    my $kernel  = $_[KERNEL];
    my $heap    = $_[HEAP];
    my $session = $_[SESSION];

    $irc->yield( register => "all" );

    $irc->yield(
        connect => {
            Nick     => $BOTNICK,
            Username => 'peoplebot',
            Password => 'fishdontbreathe',
            Ircname  => 'POE::Component::IRC cookbook bot',
            Server   => $HOST,
            Port     => $PORT,
        }
    );
    $kernel->delay( check_tells    => 10 );
    $kernel->delay( check_requests => 10 );
}

# The bot has successfully connected to a server.  Join a channel.
sub on_connect {
    $irc->yield( oper => '~peoplebot' => 'fishdontbreathe' );

}

# The bot has received a public message.  Parse it for commands, and
# respond to interesting things.
sub on_public {
    my ( $kernel, $who, $where, $msg ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];

    my $ts = scalar localtime;
    print " [$ts] <$nick:$channel> $msg\n";

    add_log( $who, $channel, 'log', $msg );

    if (   $msg =~ /^$BOTNICK,\s*(.*)/i
        || $msg =~ /^$BOTNICK\s+(.*)/i
        || $msg =~ /^${BOTNICK}:\s*(.*)/i
        || $msg =~ /^(.*)\s+${BOTNICK}\s*\?*$/i )
    {

        my ( $bot_says_pub, $bot_says_priv )
            = @{ bot_request( { question => $1, from => $who, channel => $channel } ) };
        $irc->yield( privmsg => $channel, $bot_says_pub );
        $irc->yield( privmsg => $nick, $bot_says_priv ) if ($bot_says_priv);

        # and fake the log
        add_log( $BOTNICK, $channel, 'log', $bot_says_pub );

    }

}

sub on_msg {
    my ( $kernel, $who, $what ) = @_[ KERNEL, ARG0, ARG2 ];
    my $nick = ( split /!/, $who )[0];

    my ( $bot_says_pub, $bot_says_priv )
        = @{ bot_request( { question => $what, from => $who } ) };
    if ($bot_says_priv) {
        $irc->yield( privmsg => $nick, $bot_says_priv );
    }
    else {
        $irc->yield( privmsg => $nick, $bot_says_pub );
    }
}

sub on_invite {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];
    $irc->yield( join => $where );
}

sub on_join {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where;
    $seen->{$channel}->{$nick} = 1;
    add_log( $nick, $channel, 'join', 'joined' );
    if ( $nick =~ /justin|garner|nick|adam|ev|mwp/i ) {
        $irc->yield( 'mode' => $channel => '+o' => $nick );
    }
}

sub on_topic {
    my ( $kernel, $who, $where, $topic ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $nick = ( split /!/, $who )[0];
    add_log( $nick, $where, 'topic', $topic );
}

sub on_part {
    my ( $kernel, $who, $where, $why ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where;
    $seen->{$channel}->{$nick} = 0;
    add_log( $nick, $channel, 'part', $why );
}

sub on_quit {
    my ( $kernel, $who, $why ) = @_[ KERNEL, ARG0, ARG1 ];
    my $nick = ( split /!/, $who )[0];

    # this is perhaps wrong in some edge cases?
    foreach my $channel ( keys %$seen ) {
        if ( $seen->{$channel}->{$nick} ) {
            $seen->{$channel}->{$nick} = 0;
            add_log( $nick, $channel, 'quit', $why );
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
    print join ' ', @output, "\n";
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
        my $channel = $unlogged->request->channel->name;
        my $url = 'http://' . $config->{http_server_host} . 
                  ($config->{http_server_port} ? ':' . $config->{http_server_port} : '') .
                  $config->{http_server_path} . "file/" .
                  $unlogged->id;
        my $filename = $unlogged->filename;
        $filename =~ s/.*\///;
        my $message
            = $filename
            . " has been uploaded, download it at "
            . $url;
        
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

# Run the bot until it is done.
$poe_kernel->run();
exit 0;
