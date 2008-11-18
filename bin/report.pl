#!/usr/bin/perl
use strict;
use warnings;
use Mail::Send;
use DateTime;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

# use CollabIRCate qw/-Debug/;
use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

use Config::General;
my $config = { Config::General->new("$Bin/../collabircate.conf")->getall };

my $dsn = $config->{dsn};

my $schema = CollabIRCate::Schema->connect($dsn)
  || die $!;

my $channel = shift;
my $dest    = shift;

my $start = DateTime->now->subtract( hours => 1 );

my $chan = $schema->resultset('Channel')->search( { name => $channel } )->next;
if ( !$chan ) {
    die "No such channel $channel";
}

my $log = $schema->resultset('Log')->search(
    {
        ts         => { '>=', $start },
        channel_id => $chan->id,

        #						type => 'log',
    },
    {
        order_by  => 'ts',
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

    my $mail = Mail::Send->new;
    $mail->to($dest);
    $mail->subject("What happened in the last hour on $channel");
    my $fh = $mail->open;

    foreach (@entries) {
        $this_epoch = $$_[3];
        if ($last_epoch) {
            if ( $last_epoch + 300 < $this_epoch ) {
                print $fh "\n";
            }
        }
        $last_epoch = $this_epoch;
        print $fh join ( ': ', @$_[ 0 .. 2 ] ) . "\n" if ( $$_[4] eq 'log' );
        print $fh "$$_[0]: *** topic changed to '$$_[2]' by $$_[1]\n"
          if ( $$_[4] eq 'topic' );
    }
    $fh->close;

}

