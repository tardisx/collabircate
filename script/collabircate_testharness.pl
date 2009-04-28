#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $shell;
my $help;
my $result = GetOptions("shell"  => \$shell,  # shell after start
                        "help"   => \$help);  # help
if (! $result) { pod2usage(2); exit; }
if ($help)     { pod2usage(1); exit; }

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

# set up
system ("perl", "Makefile.PL");

# deploy sql
system ("bin/deploy.pl");

# start the server and bot
my $spid = start_server();
my $bpid = start_bot();
sleep 5;

if ($shell) {
  print "Escaping to shell - remember to exit after testing\n";
  system ($ENV{SHELL});
  print "Killing servers and cleaning up\n";
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
