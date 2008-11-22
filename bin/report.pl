#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Mail::Send;
use DateTime;
use Getopt::Long;
use Carp;
use Pod::Usage;

use CollabIRCate::Config;

my $config = CollabIRCate::Config->config();
my $dsn    = $config->{dsn};
my $break  = $config->{irc_log_conversation_break};
my $schema = CollabIRCate::Config->schema;

my $debug = 0;
my $email;
my $channel;
my $minutes = 60;
my $help;

my $options_okay = GetOptions(
    'debug'     => \$debug,
    'email=s'   => \$email,
    'channel=s' => \$channel,
    'minutes=s' => \$minutes,
    'help'      => \$help,
);

if ( $help || ( !$email && !$channel ) ) {
    pod2usage( -exitval => 1 );
    exit;    # unnecessary
}

croak "bad options" unless $options_okay;
croak "need -c"     unless $channel;
croak "need -e"     unless ( $email || $debug );
croak "need -m"     unless $minutes;

my $start = DateTime->now->subtract( minutes => $minutes );
$start =~ s/T/ /;    # ugly hack

my $chan
    = $schema->resultset('Channel')->search( { name => $channel } )->next;
if ( !$chan ) {
    croak "No such channel $channel";
}

my $log = $schema->resultset('Log')->search(
    {   ts         => { '>=', $start },
        channel_id => $chan->id,

        # type => 'log',
    },
    {   order_by  => 'ts',
        join      => 'users',
        '+select' => ['users.email'],
    }
);

my @entries     = ();
my $interesting = 0;

while ( my $entry = $log->next ) {

    my $nick = $entry->users->email;
    $nick =~ s/!.*//x;
    my $line  = $entry->entry;
    my $ts    = $entry->ts;
    my $epoch = $ts->epoch;
    my $type  = $entry->type;

    $interesting = 1 if ( $type eq 'log' );

    #  ($ts) = $ts =~ /\d\d\d\d\-\d\d\-\d\d\s+(.*):\d\d\./;
    push @entries, [ $ts->hms, $nick, $line, $epoch, $type ];

}

if ( !$interesting ) {
    warn "no output because no interesting entries\n" if ($debug);
    exit 0;
}

my ($last_epoch);

if (@entries) {

    my $mail;
    my $fh;
    my $subject = "What happened in the last $minutes minutes on $channel";

    if ($debug) {
        $fh = *STDOUT;
        print $fh "Subject: $subject\n\n";
    }
    else {
        $mail = Mail::Send->new;
        $mail->to($email);
        $mail->subject($subject);
        $fh = $mail->open;
    }

    foreach my $this_entry (@entries) {
        my ( $ts, $nick, $line, $this_epoch, $type ) = @$this_entry;

        if ($last_epoch) {
            if ( $last_epoch + $break < $this_epoch ) {
                print $fh "\n";
            }
        }
        $last_epoch = $this_epoch;

        if ( $type eq 'log' ) {
            print $fh join( ': ', ( $ts, $nick, $line ) ) . "\n";
        }
        elsif ( $type eq 'topic' ) {
            print $fh "$ts: *** topic changed to '$line' by $nick\n";
        }
        elsif ( $type eq 'join' ) {
            print $fh "$ts: $nick joined\n";
        }
        elsif ( $type eq 'part' ) {
            print $fh "$ts: $nick left\n";
        }
    }
    $fh->close unless $debug;

}

exit;

__END__

=head1 NAME

report.pl - Send out a report of IRC channel activity

=head1 SYNOPSIS

report.pl -c #channel -m 60 -e person@example.com

=head1 VERSION

This documentation refers to version 0.0.1

=head1 USAGE

  bin/report.pl -c #channel -e email@example.com,email2@example.com -i 90

=head1 REQUIRED ARGUMENTS

C<-c channel> - channel to be reported against

C<-e address> - email address to be sent to

C<-m nn> - minutes of interval 

C<-d> - debug mode
  
