#!/usr/bin/env perl

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
use CollabIRCate::DB::Channel::Manager;
use CollabIRCate::DB::Log::Manager;

my $config = CollabIRCate::Config->config();
my $break  = $config->{irc_log_conversation_break};

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

my $chan = CollabIRCate::DB::Channel::Manager->get_channels(
    query => [ name => $channel ]
);

if ( !$chan || ! @$chan ) {
    croak "No such channel $channel";
}

# load the logs
my $log = CollabIRCate::DB::Log::Manager->get_logs(
    query => [ channel_id => $chan->[0]->id,
               ts => { '>=', $start } ],
    sort_by => 'ts',
);

my @entries     = ();
my $interesting = 0;

foreach my $entry ( @$log ) {

    my $nick = $entry->nick;
#    $nick =~ s/!.*//x;
    my $line  = $entry->entry;
    my $ts    = $entry->ts;
    my $epoch = $ts->epoch;
    my $type  = $entry->type;

    $interesting = 1 if (( $type eq 'log' ) || ( $type eq 'action' ));

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
    my $date = sprintf("%04d-%02d-%02d", 
                       (localtime)[5]+1900,
                       (localtime)[4]+1,
                       (localtime)[3]);
    my $subject = "$channel - $date - last $minutes minutes";

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
        elsif ( $type eq 'action' ) {
            print $fh "$ts: $nick $line\n";
        }
        elsif ( $type eq 'topic' ) {
            print $fh "$ts: *** topic changed to '$line' by $nick\n";
        }
        elsif ( $type eq 'join' ) {
            print $fh "$ts: $nick joined\n";
        }

        # these should show the witty message provided!
        elsif ( $type eq 'part' ) {
            print $fh "$ts: $nick left\n";
        }
        elsif ( $type eq 'quit' ) {
            print $fh "$ts: $nick quit\n";
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
  
Causes the output to be sent to C<STDOUT> instead of an email being sent.

