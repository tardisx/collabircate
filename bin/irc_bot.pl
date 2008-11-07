#!/usr/bin/perl

# A fairly simple example:
use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Bot qw/bot_request/;

use Mail::Send;

use Config::General;
my $config = { Config::General->new("$Bin/../collabircate.conf")->getall };

my $PORT    = $config->{irc_server_port};
my $BOTNICK = $config->{irc_bot_nickname} || 'peoplebot';

use POE;
use POE::Component::IRC;

sub CHANNEL () { "#people" }

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
        irc_msg    => \&on_msg,
        _default   => \&unknown,
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
            Server   => 'localhost',
            Port     => $PORT,
        }
    );
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
    my $nick    = ( split /!/, $who )[0];
    my $channel = $where->[0];

    my $ts = scalar localtime;
    print " [$ts] <$nick:$channel> $msg\n";

    add_log( $who, $channel, 'log', $msg );

    if (   $msg =~ /^$BOTNICK,\s*(.*)/
        || $msg =~ /^$BOTNICK\s+(.*)/
        || $msg =~ /^${BOTNICK}:\s*(.*)/
        || $msg =~ /^(.*)\s+${BOTNICK}\s*\?*$/ )
    {

        my $bot_says = bot_request( $1, $nick );
        $irc->yield( privmsg => $channel, $bot_says );

        # and fake the log
        add_log( $BOTNICK, $channel, 'log', $bot_says );

    }

}

sub on_msg {
    my ( $kernel, $who, $what ) = @_[ KERNEL, ARG0, ARG2 ];
    my $nick = ( split /!/, $who )[0];

    my $bot_says = bot_request( $what, $nick );
    $irc->yield( privmsg => $nick, $bot_says );
}

sub on_invite {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];
    $irc->yield( join => $where );
}

sub on_join {
    my ( $kernel, $who, $where ) = @_[ KERNEL, ARG0, ARG1 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where;
    add_log( $nick, $channel, 'join', 'joined' );
    if ( $nick =~ /justin/i ) {
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

# Run the bot until it is done.
$poe_kernel->run();
exit 0;