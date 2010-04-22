use strict;
use warnings;

use Test::More tests => 3;

use_ok('CollabIRCate::DB::Channel');

my $channel = CollabIRCate::DB::Channel->new(name => '#foobar');
ok( defined $channel, 'created channel');
ok ($channel->save, 'could save it');
