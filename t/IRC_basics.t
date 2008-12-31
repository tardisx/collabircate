use strict;
use warnings;
use Test::More tests => 1;

my $ret = system ("bin/irc_test.pl -s localhost -p 6668 join=#people quit=gone");
ok (! $ret, 'can join and quit');
