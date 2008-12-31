#! /usr/bin/perl
use warnings;
use strict;
use Carp;

use Getopt::Long;
use Pod::Usage;

use POE qw(Component::IRC);

my ( $debug, $server, $port, $nick );
my $success = 1;
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

my @actions   = @ARGV;
my @channels  = ();
my $quit_wait = 5;

# We create a new PoCo?IRC object
my $irc = POE::Component::IRC->spawn(
    nick    => $nick,
    ircname => "tester$$",
    server  => $server,
    port    => $port,
) or die "Oh noooo! $!";

POE::Session->create(
    package_states => [
        main => [
            qw(_default _start irc_001 irc_disconnected process waitfor)],
    ],
    heap => { irc => $irc },
);

$poe_kernel->run();

sub _start {
    my $heap   = $_[HEAP];
    my $kernel = $_[KERNEL];

    # retrieve our component?s object from the heap where we stashed it
    my $irc = $heap->{irc};

    $irc->yield( register => 'all' );
    $irc->yield( connect  => {} );
    $heap->{messages} = [];
    $heap->{waitfor} = {};
    return;
}

sub irc_001 {
    my $sender = $_[SENDER];
    my $kernel = $_[KERNEL];

    # Since this is an irc_* event, we can get the component?s object by
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

sub _default {
    my ( $heap, $event, $args ) = @_[ HEAP, ARG0 .. $#_ ];

    my @interesting = qw/irc_msg irc_public/;
    
    my @output = ("$event: ");

    if (grep /$event/, @interesting) {
        for my $arg (@$args) {
            if ( ref $arg eq 'ARRAY' ) {
                push( @output, '[' . join( ' ,', @$arg ) . ']' );
                push @{ $heap->{messages} }, '[' . join( ' ,', @$arg ) . ']';
            }
            else {
                push( @output, "'$arg'" );
                push @{ $heap->{messages} }, "'$arg'";
            }
        }
        print join ' ', @output, "\n";
    }
    else {
      warn "ignoring $event\n" if $debug;
    }
    return 0;
}

sub waitfor {
  my ($kernel, $heap, $regexp, $timeout) = @_[KERNEL, HEAP, ARG0, ARG1];
  $timeout--;
  if (! $timeout) {
    warn "[$regexp] timeout!";
    delete $heap->{waitfor}->{$regexp};
    $success = 0;
    return;
  }


  warn "[$regexp] $timeout remaining";

  # init the index pointer for this regexp if we don't have one
  if (! defined $heap->{waitfor}->{$regexp}) {
    warn "[$regexp] initting pointer";
    $heap->{waitfor}->{$regexp} = scalar @{ $heap->{messages} };
  }

  # iterate through the messages we haven't looked at
  my $found = 0;
  foreach ( $heap->{waitfor}->{$regexp} .. scalar @{ $heap->{messages} } - 1) {
    my $message = $heap->{messages}->[$_];
    if ($message =~ /$regexp/) {
      print "WOO $regexp in $message\n";
      $found = 1;
    }
  }

  if (! $found) {
    # record we are up to here now
    $heap->{waitfor}->{$regexp} = scalar @{ $heap->{messages} };
    # and do it again
    warn "[$regexp] re-queueing $timeout";
    $kernel->delay_add( waitfor => 1, $regexp, $timeout );
  }

  else {
    # no need to do this anymore!
    warn "[$regexp] is done";
    delete $heap->{waitfor}->{$regexp};
  }

}

sub process {
  my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];

  if ( !@actions ) {
    $irc->yield( 'quit' => 'finished all commands' );
    $irc->yield('shutdown');
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
    elsif ( $key eq 'part' ) {
      $irc->yield( 'part' => $value );
    }
    elsif ( $key eq 'waitfor' ) {
      my ( $regexp, $delay ) = split /,/, $value;
      $kernel->yield( 'waitfor', $regexp, $delay );
    }
    elsif ( $key eq 'quit' ) {
      # do this again in a moment if we still have outstanding
      # waitfors
      if ( keys %{ $heap->{waitfor} } ) {
        unshift @actions, "$key=$value";
      }
      else {
        $irc->yield( 'quit' => $value );
        $irc->yield('shutdown');
      }
    }
    elsif ( $key eq 'privmsg' ) {
      $irc->yield( 'privmsg' => split /,/, $value );
    }
    else {
      warn "don't know how to deal with $action";
    }

    $kernel->yield('process');
  }

}

sub irc_disconnected {

    # happy ending!
    warn "got irc_disconnect";

}

END {

    exit 1 - $success;
}
__END__

=head1 NAME

irc_test.pl - test an irc server and bot

=head1 SYNOPSIS

irc_test.pl -s server.example.com -p 6669 command=value [command=value ....]

=head1 VERSION

This documentation refers to version 0.0.1

=head1 USAGE

  bin/irc_test.pl -s server.example.com -p 6669 -n testbot join=#people privmsg=#people,Hello quit=BYE

=head1 REQUIRED ARGUMENTS

C<-s server> - irc server to connect to

C<-d> - debug mode
  
C<-p> - port number

C<-n> - starting nick
