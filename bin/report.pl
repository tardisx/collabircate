#!/usr/bin/perl
use strict;
use warnings;
use Mail::Send;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

# use YAML qw/LoadFile/;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));

my $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
  || die $!;

my $channel = shift;
my $dest = shift;

my $interval = "> now() - '1 hour'::INTERVAL";

my $chan = $schema->resultset('Channel')->search({name => $channel})->next;
if (! $chan) {
    die "No such channel $channel";
}

my $log = $schema->resultset('Log')->search({ts => \$interval, channel_id => $chan->channel_id});

my @entries = ();

while (my $entry = $log->next) {
  my $nick = $entry->user_id->email;
  $nick =~ s/!.*//;
  my $line  = $entry->entry;
  my $ts = $entry->ts;
  ($ts) = $ts =~ /\d\d\d\d\-\d\d\-\d\d\s+(.*):\d\d\./;
  push @entries, [$ts, $nick, $line];
}

if (@entries) {

  my $mail = Mail::Send->new;
  $mail->to($dest);
  $mail->subject("What happened in the last hour on $channel");
  my $fh = $mail->open;
 
  foreach (@entries) {
    print $fh join (': ', @$_) . "\n";
  }
  $fh->close;

}
