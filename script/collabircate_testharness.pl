#!/usr/bin/perl

use strict;
use warnings;

my $store = '/tmp/store' . $$;

my $db = "/tmp/db" . $$;
my $dsn   = "dbi:SQLite:dbname=$db";

$ENV{COLLABIRCATE_CONFIG_FILE_STORE_PATH} = $store;
$ENV{COLLABIRCATE_CONFIG_DSN} = $dsn;

if (-e "collabircate.conf") {
  system ("cp", "collabircate.conf", "collabircate.conf.preserved");
}
system ("cp", "collabircate.conf.sample", "collabircate.conf");
mkdir $store;

system ("perl", "Makefile.PL");
system ("bin/deploy.pl");
system ("make", "test");

END {
  if (-e "collabircate.conf.preserved") {
    system ("mv", "collabircate.conf.preserved", "collabircate.conf");
  }
  system ("rm", $db);
  system ("rm", "-rf", $store);
}
