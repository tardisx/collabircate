#!/usr/bin/perl

use strict;
use warnings;

use Carp qw/croak/;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use POE qw(Component::Server::IRC);

use CollabIRCate::Logger;
use Config::Any;

my $configs = Config::Any->load_files({files => ["collabircate.conf"]});
my $config = $configs->[0]->{'collabircate.conf'};

my $PORT = $config->{irc_server_port} || 6669;
my $debug = 0;

my %config = (
    servername => $config->{irc_server_name} || 'localhost',
    nicklen    => 15,
    network    => $config->{irc_server_name},
    motd       => \@{ $config->{irc_server_motd} },
);

my $pocosi = POE::Component::Server::IRC->spawn( config => \%config );

my $logger = CollabIRCate::Logger->get('irc_server');

$logger->info("creating session");
POE::Session->create(
    package_states =>
        [ 'main' => [qw(_start _default ircd_listener_failure   )], ],
    heap => { ircd => $pocosi },
);

$logger->info("starting kernel");
$poe_kernel->run();
exit 0;

sub _start {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    $heap->{ircd}->yield('register');

    # Anyone connecting from the loopback gets spoofed hostname
    $heap->{ircd}->add_auth(
        mask     => '*@localhost',
        spoof    => 'm33p.com',
        no_tilde => 1
    );

    $heap->{ircd}->add_auth( mask => '*@*' );

    # Start a listener on the 'standard' IRC port.
    $heap->{ircd}->add_listener( port => $PORT );

    undef;
}

sub _default {
    my ( $kernel, $event, $args ) = @_[ KERNEL, ARG0 .. $#_ ];
    print STDOUT "$event: " if ($debug);

    # ircd_daemon_join: 'tardisx!~mobile@121.45.172.28' '#people'
    # ircd_daemon_quit: 'tardisx!~mobile@121.45.172.28' 'Client Quit'
    # ircd_daemon_quit: 'tardisx!~mobile@121.45.172.28' '"iPhone lock/sleep"'
    # ircd_daemon_privmsg: 'tardisx!~justin@121.45.172.28' 'peoplebot' 'ops'

    foreach (@$args) {
    SWITCH: {
            if ( ref($_) eq 'ARRAY' ) {
                print STDOUT "[", join( ", ", @$_ ), "] " if ($debug);
                last SWITCH;
            }
            if ( ref($_) eq 'HASH' ) {
                print STDOUT "{", join( ", ", %$_ ), "} " if ($debug);
                last SWITCH;
            }
            print STDOUT "'$_' " if ($debug);
        }
    }
    print STDOUT "\n" if ($debug);
    return 0;    # Don't handle signals.
}

sub ircd_listener_failure {
   my ($reason) = $_[ARG3];

   croak "Could not start server: $reason";
}
