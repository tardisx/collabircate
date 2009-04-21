use strict;
use warnings;
use Test::More tests => 4;

my $ret = system ("bin/irc_test.pl -s localhost -p 6668 join=#people quit=gone");
ok (! $ret, 'can join and quit');

$ret = system("bin/irc_test.pl -s localhost -p 6668 join=#people invite=undefBOT,#people sleep=1 quit=bye");
ok (! $ret, 'invite the bot');

$ret = system("bin/irc_test.pl", '-s', 'localhost', '-p', '6668', 'join=#people', 'privmsg=#people,undefBOT: google collabircate', 'sleep=2', 'waitfor=GitHub,9', 'sleep=2');
ok (! $ret, 'google command to bot works');

$ret = system("bin/irc_test.pl", '-s', 'localhost', '-p', '6668', 'join=#people', 'privmsg=#people,undefBOT: what is 600 + 60 + 6 ?', 'waitfor=666,9', 'sleep=2');
ok (! $ret, 'bot can do maths');
