use strict;
use warnings;
use CollabIRCate::Config;

use Test::More tests => 2;

my $schema = CollabIRCate::Config->schema;

ok( defined $schema, 'got schema object' );

my $user = $schema->resultset('Users')->create({email => 'justin@hawkins.id.au',
                                                password => 'justin'});
ok( defined $user, 'created user');
                                                
