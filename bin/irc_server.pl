#!/usr/bin/perl

# A fairly simple example:
use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use POE qw(Component::Server::IRC);
use Mail::Send;

use CollabIRCate::Log qw/add_log/;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));


my $MAIL_DELAY = 3600;
my $SUPER_USER = 'justin';
my $PORT       = 6668;

my @TO = ('justin@hawkins.id.au');

my %config = (
    servername => 'romana.hawkins.id.au',
    nicklen    => 15,
    network    => 'nickNET',
    motd       => [
        'all you could ever want in a server',
        'and so much much more',
        'try the beef - moo',
    ],
);

my $pocosi = POE::Component::Server::IRC->spawn( config => \%config );

POE::Session->create(
    package_states => [
        'main' => [
            qw(_start _default
              ircd_daemon_public ircd_daemon_join ircd_daemon_quit ircd_daemon_privmsg ircd_daemon_nick
              )
        ],
    ],
    heap => { ircd => $pocosi },
);

$poe_kernel->run();
exit 0;

sub ircd_daemon_nick {
  my ( $kernel, $heap, $nick, $umode, $hostname, $realname) = 
      @_[ KERNEL, HEAP, ARG0, ARG3, ARG5, ARG7];
  warn "Hello to $nick ($umode) from $hostname, he is called $realname";
}

sub ircd_daemon_privmsg {
    my ( $kernel, $heap, $from, $to, $what ) =
      @_[ KERNEL, HEAP, ARG0, ARG1, ARG2 ];
    $from =~ s/!.*//;

#    warn "giving ops to $SUPER_USER because $from wrote to $to ($what)";
#    $heap->{ircd}->yield( 'daemon_cmd_mode', $SUPER_USER, '#people', '+o' );
#    $heap->{ircd}->yield(
#        'daemon_cmd_privmsg', 'peoplebot',
#        '#people',            "$from said to me, \"$what\""
#    );
    if ($what =~ /^topic\s+(#\S+)\s+(.*)/) {
			    $heap->{ircd}->yield(
						 'daemon_cmd_topic', 'peoplebot', $1, $2 );
			    $heap->{ircd}->yield( 'daemon_cmd_mode', 'justin', '#people', '+o' );
			}

}

sub ircd_daemon_join {
    my ( $kernel, $heap, $who, $where ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
#    $who =~ s/!.*//;
    $heap->{ircd}->yield( 'daemon_cmd_sjoin', 'peoplebot', $where );

    add_log($who, $where, 'join', 'joined');

}

sub ircd_daemon_quit {
    my ( $kernel, $heap, $who, $why ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
#    $who =~ s/!.*//;
    warn "$who quit but I don't yet know where they were\n";

}

sub ts_to_hhmm {
    my $ts = shift;
    return sprintf( "%02d:%02d", ( localtime($ts) )[ 2, 1 ] );
}

sub ircd_daemon_public {
    my ( $kernel, $heap, $who, $where, $what ) =
      @_[ KERNEL, HEAP, ARG0, ARG1, ARG2 ];
#    $who =~ s/!.*//;

    add_log($who, $where, 'log', $what);

    push @{ $heap->{log}->{$where} }, [ time(), "$who: $what" ]
      unless $what =~ /ACTION /;
    push @{ $heap->{log}->{$where} }, [ time(), "$who $what" ]
      if $what =~ s/ACTION //;
    $heap->{interesting_log} = 1;
}

sub _start {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    $heap->{ircd}->yield('register');

    # Anyone connecting from the loopback gets spoofed hostname
    $heap->{ircd}
      ->add_auth( mask => '*@localhost', spoof => 'm33p.com', no_tilde => 1 );

    # We have to add an auth as we have specified one above.
#    $heap->{ircd}->add_auth( mask => '~justin@hawkins.id.au@*', password => 'fungula', no_tilde => 1 );

    $heap->{ircd}->add_auth( mask => '*@*' );

    # Start a listener on the 'standard' IRC port.
    $heap->{ircd}->add_listener( port => $PORT );

    # Add an operator who can connect from localhost
    $heap->{ircd}
      ->add_operator( { username => 'justin', password => 'fishdontbreathe' } );

    my $time = time();
    $heap->{ircd}->yield(
        'add_spoofed_nick',
        {
            nick    => 'peoplebot',
            ts      => $time,
            ircname => 'PeopleBot',
            umode   => 'i'
        }
    );

    undef;
}

sub _default {
    my ( $kernel, $event, $args ) = @_[ KERNEL, ARG0 .. $#_ ];
    print STDOUT "$event: ";

    # ircd_daemon_join: 'tardisx!~mobile@121.45.172.28' '#people'
    # ircd_daemon_quit: 'tardisx!~mobile@121.45.172.28' 'Client Quit'
    # ircd_daemon_quit: 'tardisx!~mobile@121.45.172.28' '"iPhone lock/sleep"'
    # ircd_daemon_privmsg: 'tardisx!~justin@121.45.172.28' 'peoplebot' 'ops'

    foreach (@$args) {
      SWITCH: {
            if ( ref($_) eq 'ARRAY' ) {
                print STDOUT "[", join( ", ", @$_ ), "] ";
                last SWITCH;
            }
            if ( ref($_) eq 'HASH' ) {
                print STDOUT "{", join( ", ", %$_ ), "} ";
                last SWITCH;
            }
            print STDOUT "'$_' ";
        }
    }
    print STDOUT "\n";
    return 0;    # Don't handle signals.
}
