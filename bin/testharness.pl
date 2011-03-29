#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Carp qw/croak/;

my $shell;
my $help;
my $result = GetOptions("shell"  => \$shell,  # shell after start
                        "help"   => \$help);  # help
if (! $result) { pod2usage(2); exit; }
if ($help)     { pod2usage(1); exit; }

if ($ENV{COLLABIRCATE_INSIDE_HARNESS}) {
    croak "Attempted to star the test harness from within the harness!";
}

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

# deploy sql
system ("sqlite3 $db < etc/schema_sqlite.sql");

# start the server and bot
my $spid = start_server();
my $bpid = start_bot();
my $wpid = start_web();
sleep 5;

# set the variable so that tests can see that they are inside
# the harness
$ENV{'COLLABIRCATE_INSIDE_HARNESS'} = 1;

if ($shell) {
  print "Escaping to shell - remember to exit after testing\n";
  # So that end-to-end tests know they can run.
  print "DB: $db\n";
  system ($ENV{SHELL});
  print "Killing servers and cleaning up\n";
}
else {
  system ("make", "test");
} 

kill "TERM", $bpid;
kill "TERM", $spid;
kill "TERM", $wpid;

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

sub start_web {
  if (my $pid = fork()) {
    return $pid;
  }
  else {
    exec "bin/web.pl daemon";
  }
}

END {
  if (-e "collabircate.conf.preserved") {
    system ("mv", "collabircate.conf.preserved", "collabircate.conf");
  }
  elsif (-e "collabircate.conf") {
    system ("rm", "collabircate.conf");
  }
  system ("rm", $db) if ($db && -e $db);
  system ("rm", "-rf", $store) if ($store && -d $store);
  system ("rm", "-rf", $queue) if ($queue && -d $queue);
  print "Cleanup complete\n";
}

__END__

=head1 NAME

collabircate_testharnesspl - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

  script/collabircate_testharness.pl [options]

 Options:
  --help            brief help message
  --shell           escape to shell after setting up server and bot
