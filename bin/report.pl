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

use CollabIRCate::Config;

my $config = CollabIRCate::Config->config();
my $dsn    = $config->{dsn};
my $schema = CollabIRCate::Config->schema;

my $debug = 0;
my $email;
my $channel;
my $minutes;

my $options_okay = GetOptions(
    'debug'     => \$debug,
    'email=s'   => \$email,
    'channel=s' => \$channel,
    'minutes=s' => \$minutes,
);

croak "bad options" unless $options_okay;
croak "need -c"     unless $channel;
croak "need -e"     unless $email;
croak "need -m"     unless $minutes;

my $start = DateTime->now->subtract( minutes => $minutes );
$start =~ s/T/ /;    # ugly hack

my $chan
    = $schema->resultset('Channel')->search( { name => $channel } )->next;
if ( !$chan ) {
    die "No such channel $channel";
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

my @entries = ();

while ( my $entry = $log->next ) {

    next unless ( $entry->type eq 'log'
        || $entry->type eq 'topic' );

    my $nick = $entry->users->email;
    $nick =~ s/!.*//;
    my $line  = $entry->entry;
    my $ts    = $entry->ts;
    my $epoch = $ts->epoch;
    my $type  = $entry->type;

    #  ($ts) = $ts =~ /\d\d\d\d\-\d\d\-\d\d\s+(.*):\d\d\./;
    push @entries, [ $ts->hms, $nick, $line, $epoch, $type ];

}

my ( $last_epoch, $this_epoch );

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
        $mail->subject("What happened in the last hour on $channel");
        $fh = $mail->open;
    }

    foreach (@entries) {
        $this_epoch = $$_[3];
        if ($last_epoch) {
            if ( $last_epoch + 300 < $this_epoch ) {
                print $fh "\n";
            }
        }
        $last_epoch = $this_epoch;
        print $fh join( ': ', @$_[ 0 .. 2 ] ) . "\n" if ( $$_[4] eq 'log' );
        print $fh "$$_[0]: *** topic changed to '$$_[2]' by $$_[1]\n"
            if ( $$_[4] eq 'topic' );
    }
    $fh->close unless $debug;

}

