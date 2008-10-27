#!/usr/bin/perl
use strict;
use warnings;
use Mail::Send;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;
use DateTime;

use CollabIRCate qw/-Debug/;
use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

my $dsn = CollabIRCate->config->{dsn};

my $schema = CollabIRCate::Schema->connect($dsn)
  || die $!;

my $channel = shift;
my $dest = shift;

my $interval = "> now() - '1 hour'::INTERVAL";

my $chan = $schema->resultset('Channel')->search({name => $channel})->next;
if (! $chan) {
    die "No such channel $channel";
}

my $log = $schema->resultset('Log')->search(
					    {ts => \$interval, channel_id => $chan->channel_id},
					    {order_by => 'ts'},
					    );

my @entries = ();

while (my $entry = $log->next) {
  my $nick = $entry->user_id->email;
  $nick =~ s/!.*//;
  my $line  = $entry->entry;
  my $ts = $entry->ts;
  my $epoch = epoch($ts);

  ($ts) = $ts =~ /\d\d\d\d\-\d\d\-\d\d\s+(.*):\d\d\./;
  push @entries, [$ts, $nick, $line, $epoch];
}

my ($last_epoch, $this_epoch);

if (@entries) {

  my $mail = Mail::Send->new;
  $mail->to($dest);
  $mail->subject("What happened in the last hour on $channel");
  my $fh = $mail->open;
 
  foreach (@entries) {
      $this_epoch = $$_[3];
      if ($last_epoch) {
	  if ($last_epoch + 300 < $this_epoch) {
	      print $fh "\n";
	  }
      }
      $last_epoch = $this_epoch;
      print $fh  join (': ', @$_[0..2]) . "\n";
  }
  $fh->close;

}

sub epoch {
    my $ts = shift;

    $ts =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d) (\d\d):(\d\d):(\d\d)/;

    die if (! $6);
    my $dt = DateTime->new( year   => $1,
			    month  => $2,
			    day    => $3,
			    hour   => $4,
			    minute => $5,
			    second => $6,
			    );

    return $dt->epoch;
}

