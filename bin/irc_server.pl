#!/usr/bin/perl

# A fairly simple example:
use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use POE qw(Component::Server::IRC);
use Mail::Send;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));

my $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
  || die $!;

my $mail_delay = 3600;
my $super      = 'justin';

my @to = ('people@hawkins.id.au');

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
              ircd_daemon_public ircd_daemon_join ircd_daemon_quit ircd_daemon_privmsg
              mail_logs)
        ],
    ],
    heap => { ircd => $pocosi },
);

$poe_kernel->run();
exit 0;

sub ircd_daemon_privmsg {
    my ( $kernel, $heap, $from, $to, $what ) =
      @_[ KERNEL, HEAP, ARG0, ARG1, ARG2 ];
    $from =~ s/!.*//;

    warn "giving ops to $super because $from wrote to $to ($what)";
    $heap->{ircd}->yield( 'daemon_cmd_mode', $super, '#people', '+o' );
    $heap->{ircd}->yield(
        'daemon_cmd_privmsg', 'peoplebot',
        '#people',            "$from said to me, \"$what\""
    );
}

sub ircd_daemon_join {
    my ( $kernel, $heap, $who, $where ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
    $who =~ s/!.*//;
    push @{ $heap->{log}->{$where} }, [ time(), "$who joined the channel" ];
}

sub ircd_daemon_quit {
    my ( $kernel, $heap, $who, $why ) = @_[ KERNEL, HEAP, ARG0, ARG1 ];
    $who =~ s/!.*//;
    warn "$who quit but I don't yet know where they were\n";

}

sub mail_logs {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];

    # queue the next one
    $kernel->delay( mail_logs => $mail_delay );

    use Data::Dumper;

    return unless defined $heap->{log};
    return unless defined $heap->{log}->{'#people'};
    return unless scalar @{ $heap->{log}->{'#people'} };

    return unless $heap->{interesting_log};

    my $mail = Mail::Send->new;
    $mail->to(@to);
    $mail->subject("What happened in the last $mail_delay seconds");
    my $fh = $mail->open;

    print $fh join ( "\n",
        map { ts_to_hhmm( $_->[0] ) . ": " . $_->[1] }
          @{ $heap->{log}->{'#people'} } );
    $fh->close;

    delete $heap->{log}->{'#people'};
    $heap->{interesting_log} = 0;

}

sub ts_to_hhmm {
    my $ts = shift;
    return sprintf( "%02d:%02d", ( localtime($ts) )[ 2, 1 ] );
}

sub ircd_daemon_public {
    my ( $kernel, $heap, $who, $where, $what ) =
      @_[ KERNEL, HEAP, ARG0, ARG1, ARG2 ];
    $who =~ s/!.*//;

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
    $heap->{ircd}->add_auth( mask => '*@*' );

    # Start a listener on the 'standard' IRC port.
    $heap->{ircd}->add_listener( port => 6668 );

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
    $heap->{ircd}->yield( 'daemon_cmd_join', 'peoplebot', '#people' );

    $kernel->delay( mail_logs => $mail_delay );

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
