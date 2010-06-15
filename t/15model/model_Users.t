use strict;
use warnings;

use Test::More tests => 3;

use_ok('CollabIRCate::DB::User');

my $user = CollabIRCate::DB::User->new(email => 'justin@hawkins.id.au'.$$);
ok( defined $user, 'created user');
ok ($user->save, 'could save it');
