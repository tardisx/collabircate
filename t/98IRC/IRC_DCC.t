use strict;
use warnings;
use Test::More;

unless ($ENV{'COLLABIRCATE_INSIDE_HARNESS'}) {
    plan skip_all => 'Not inside harness';
}
else {
    plan tests => 1;
    ok (1, 'hack');
}
