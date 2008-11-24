use strict;
use warnings;
use Test::More tests => 3;

use CollabIRCate::Config;

my $schema = CollabIRCate::Config->schema;

ok( defined $schema, 'got schema object' );

my $files = $schema->resultset('File');
ok( defined $files, 'got some File resultset' );

my $file = $files->create(
    {   filename  => '/tmp/one.txt',
    }
);

ok( defined $file->id && $file->id > 0, 'got a good file id' );


