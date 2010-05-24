use strict;
use warnings;
# use Test::More tests => 5;
use Test::More skip_all => 'need to remove all dbix::class stuff';

use File::Temp qw/tempfile/;

use CollabIRCate::Config;
use CollabIRCate::File qw/accept_file/;

my $schema = CollabIRCate::Config->schema;

ok( defined $schema, 'got schema object' );

my $reqs = $schema->resultset('Request');
ok( defined $reqs, 'got some reqs resultset' );

my $req = $reqs->create( {} );

ok( defined $req->id && $req->id > 0, 'got a good req id' );

ok( defined $req->hash && length( $req->hash ) == 32, 'got a good hash' );

my $hash = $req->hash;
my ( $fh, $filename ) = tempfile("TESTREQXXXXXXXX");
rename $filename, $filename . ".txt";
$filename .= ".txt";
print $fh "awesome\n";
close $fh;

# now try to accept it
ok ( accept_file( $filename, $hash ), 'accepted it');

# remove it
unlink $filename;
