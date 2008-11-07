#!/usr/bin/perl

# A fairly simple example:
use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use POE qw(Component::Server::IRC);
use Mail::Send;

use CollabIRCate qw/Debug/;
#use CollabIRCate::Log qw/add_log/;

my $PORT       = CollabIRCate->config->{irc_server_port};

my %config = (
    servername => 'romana.hawkins.id.au',
    nicklen    => 15,
    network    => CollabIRCate->config->{irc_server_name},
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
            qw(_start _default                         )
        ],
    ],
    heap => { ircd => $pocosi },
);

$poe_kernel->run();
exit 0;

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
      ->add_operator( { username => 'peoplebot', password => 'fishdontbreathe' } );

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
