use strict;
use warnings;
use Test::More tests => 3;

my $ret = system ("bin/irc_test.pl -s localhost -p 6668 join=#people quit=gone");
ok (! $ret, 'can join and quit');

$ret = system("bin/irc_test.pl -s localhost -p 6668 join=#people invite=undefBOT,#people sleep=1 quit=bye");
ok (! $ret, 'invite the bot');

$ret = system("bin/irc_test.pl", '-s', 'localhost', '-p', '6668', 'join=#people', 'privmsg=#people,undefBOT: google collabircate', 'waitfor=eatmorecode,5');
ok (! $ret, 'google command to bot works');

