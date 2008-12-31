#!/usr/bin/perl

use strict;
use warnings;

my $store = '/tmp/store' . $$;
my $queue = '/tmp/queue' . $$;

my $db = "/tmp/db" . $$;
my $dsn   = "dbi:SQLite:dbname=$db";

$ENV{COLLABIRCATE_CONFIG_FILE_STORE_PATH} = $store;
$ENV{COLLABIRCATE_CONFIG_EMAIL_QUEUE_PATH} = $queue;
$ENV{COLLABIRCATE_CONFIG_DSN} = $dsn;

if (-e "collabircate.conf") {
  system ("cp", "collabircate.conf", "collabircate.conf.preserved");
}
system ("cp", "collabircate.conf.sample", "collabircate.conf");
mkdir $store;
mkdir $queue;

system ("perl", "Makefile.PL");
system ("bin/deploy.pl");

# start the server and bot
my $spid = start_server();
my $bpid = start_bot();
sleep 5;

if (@ARGV) {
  system ($ENV{SHELL});
}
else {
  system ("make", "test");
} 

kill "TERM", $bpid;
kill "TERM", $spid;

sub start_server {
  if (my $pid = fork()) {
    return $pid;
  }
  else {
    exec "bin/irc_server.pl";
  }
}

sub start_bot {
  if (my $pid = fork()) {
    return $pid;
  }
  else {
    exec "bin/irc_bot.pl";
  }
}

END {
  if (-e "collabircate.conf.preserved") {
    system ("mv", "collabircate.conf.preserved", "collabircate.conf");
  }
  else {
    system ("rm", "collabircate.conf");
  }
  system ("rm", $db);
  system ("rm", "-rf", $store);
  system ("rm", "-rf", $queue);
}
