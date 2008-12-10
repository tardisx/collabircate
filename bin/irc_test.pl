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
            qw(_default _start irc_001 irc_disconnected process )],
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
    my ( $event, $args ) = @_[ ARG0 .. $#_ ];

    my @interesting = qw/irc_msg irc_public/;
    
    my @output = ("$event: ");

    if (grep /$event/, @interesting) {
        for my $arg (@$args) {
            if ( ref $arg eq 'ARRAY' ) {
                push( @output, '[' . join( ' ,', @$arg ) . ']' );
            }
            else {
                push( @output, "'$arg'" );
            }
        }
        print join ' ', @output, "\n";
    }
    else {
      warn "ignoring $event\n" if $debug;
    }
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
        elsif ( $key eq 'part' ) {
            $irc->yield( 'part' => $value );
        }
        elsif ( $key eq 'quit' ) {
            push @actions, 'sleep=3';
            $irc->yield( 'quit' => $value );
        }
        elsif ( $key eq 'privmsg' ) {
            $irc->yield( 'privmsg' => split /,/, $value );
        }
        else {
            warn "don't know how to deal with $action";
        }

    }
    $kernel->yield('process');

}

sub irc_disconnected {

    # happy ending!
    exit;

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
