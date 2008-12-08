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

my $config = CollabIRCate::Config->config;

my $HOST    = $config->{irc_bot_server_host} || croak "no server host";
my $PORT    = $config->{irc_bot_server_port} || croak "no server port";
my $BOTNICK = $config->{irc_bot_nickname}    || 'undefBOT';

use POE;
use POE::Component::IRC;

my $seen = {};

sub CHANNEL () {"#people"}

# Create the component that will represent an IRC network.
my ($irc) = POE::Component::IRC->spawn();

# Create the bot session.  The new() call specifies the events the bot
# knows about and the functions that will handle those events.
POE::Session->create(
    inline_states => {
        _start      => \&bot_start,
        irc_001     => \&on_connect,
        irc_public  => \&on_public,
        irc_invite  => \&on_invite,
        irc_join    => \&on_join,
        irc_topic   => \&on_topic,
        irc_part    => \&on_part,
        irc_msg     => \&on_msg,
        _default    => \&unknown,
        check_tells => \&check_tells,
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
    $kernel->delay( check_tells => 10 );
}

# The bot has successfully connected to a server.  Join a channel.
sub on_connect {
    $irc->yield( oper => '~peoplebot' => 'fishdontbreathe' );

    $irc->yield( join => CHANNEL );
    $irc->yield( join => '#vps' );
    $irc->yield( join => '#collabIRCate' );
    $irc->yield( join => '#random' );
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
            = @{ bot_request( { question => $1, from => $who } ) };
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
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where;
    $seen->{$channel}->{$nick} = 0;
    add_log( $nick, $channel, 'part', 'left' );
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

# Run the bot until it is done.
$poe_kernel->run();
exit 0;
