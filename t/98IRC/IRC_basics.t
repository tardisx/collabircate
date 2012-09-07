use strict;
use warnings;
use Test::More;

unless ($ENV{'COLLABIRCATE_INSIDE_HARNESS'}) {
    plan skip_all => 'Not inside harness';
}
else {
    plan tests => 3;
}

my $ret = system ("bin/irc_test.pl -s localhost -p 6668 join=#people quit=gone");
ok (! $ret, 'can join and quit');

$ret = system("bin/irc_test.pl -s localhost -p 6668 join=#people invite=undefBOT,#people sleep=1 quit=bye");
ok (! $ret, 'invite the bot');

$ret = system("bin/irc_test.pl", '-s', 'localhost', '-p', '6668', 'join=#people', 'privmsg=#people,undefBOT: what is 600 + 60 + 6 ?', 'waitfor=666,19');
ok (! $ret, 'bot can do maths');

=pod 

$ret = system("bin/irc_test.pl", '-s', 'localhost', '-p', '6668', 'join=#people', 'privmsg=#people,undefBOT: version', 'waitfor=I am version,19');
ok (! $ret, 'bot knows what version he is');

=cut
