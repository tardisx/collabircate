#! /usr/bin/perl
use warnings;
use strict;
use Carp;

use Getopt::Long;
use Pod::Usage;

use POE qw(Component::IRC);

my ( $debug, $server, $port, $nick );
my $help = 0;

my $options_okay = GetOptions(
  'debug'      => \$debug,
  'help'       => \$help,
  'server=s'   => \$server,
  'port=i'     => \$port,
  'nickname=s' => \$nick,
);

if ( $help || ( !$server && !$port ) ) {
  pod2usage( -exitval => 1 );
  exit;    # unnecessary
}

$nick = "tester$$" unless $nick;

my @actions = @ARGV;
my @channels = ();
my $quit_wait = 5;

# We create a new PoCo−IRC object
my $irc = POE::Component::IRC->spawn(
  nick    => $nick,
  ircname => "tester$$",
  server  => $server,
  port    => $port,
) or die "Oh noooo! $!";

POE::Session->create(
  package_states => [ main => [qw(_default _start irc_001 irc_public irc_disconnected process )], ],
  heap           => { irc  => $irc },
);

$poe_kernel->run();

sub _start {
  my $heap = $_[HEAP];
  my $kernel = $_[KERNEL];

  # retrieve our component’s object from the heap where we stashed it
  my $irc = $heap->{irc};

  $irc->yield( register => 'all' );
  $irc->yield( connect => { } );
  return;
}


sub irc_001 {
  my $sender = $_[SENDER];
  my $kernel = $_[KERNEL];

  # Since this is an irc_* event, we can get the component’s object by
  # accessing the heap of the sender. Then we register and connect to the
  # specified server.
  my $irc = $sender->get_heap();

  print "Connected to ", $irc->server_name(), "\n";

  # we join our channels
  $irc->yield( join => $_ ) for @channels;

  # start processing our list of TODOs
  $kernel->yield('process');
  
  return;
}

sub irc_public {
  my ( $sender, $who, $where, $what ) = @_[ SENDER, ARG0 .. ARG2 ];
  my $nick = ( split /!/, $who )[0];
  my $channel = $where->[0];

  if ( my ($rot13) = $what =~ /^rot13 (.+)/ ) {
    $rot13 =~ tr[a−zA−Z][n−za−mN−ZA−M];
    $irc->yield( privmsg => $channel => "$nick: $rot13" );
  }
  return;
}

sub _default {
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

sub process {
  my $kernel = $_[KERNEL];

  if ( !@actions ) {
    $quit_wait--;
    warn "Waiting $quit_wait";
    if ( !$quit_wait ) {
      die "we did not disconnect";
    }
    $kernel->delay( 'process' => 1 );
  }
  else {
    my $action = shift @actions;

    my ( $key, $value ) = $action =~ m/(\w+)=(.+)$/;
    if ( $key eq 'nick' ) {
      warn "Changing nick to $value";
      $irc->yield( 'nick' => $value );
    }
    elsif ( $key eq 'sleep' ) {
      $kernel->delay( 'process' => $value );
      return;
    }
    elsif ( $key eq 'join' ) {
      $irc->yield( 'join' => $value );
    }
    elsif ($key eq 'part') {
      $irc->yield( 'part' => $value );
    }
    elsif ( $key eq 'quit' ) {
      push @actions, 'sleep=3';
      $irc->yield( 'quit' => $value );
    }
    else {
      warn "don't know how to deal with $action";
    }

  }
  $kernel->yield('process');

}

sub irc_disconnected {

  warn "Happy ending\n";
  exit;

}
