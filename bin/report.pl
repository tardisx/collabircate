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

my $interval = "> now() - '1 hour'::INTERVAL";
my $log = $schema->resultset('Log')->search({ts => \$interval});


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
  $mail->to('people@hawkins.id.au');
  $mail->subject("What happened in the last hour");
  my $fh = $mail->open;
 
  foreach (@entries) {
    print $fh join (': ', @$_) . "\n";
  }
  $fh->close;

}
