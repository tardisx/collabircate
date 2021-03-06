use strict;
use warnings;
# use Test::More tests => 3;
use Test::More skip_all => 'need to remove all dbix::class stuff';

use File::Temp qw/tempfile/;

use CollabIRCate::Config;
use CollabIRCate::File qw/accept_file/;

  my $schema = CollabIRCate::Config->schema;

  ok( defined $schema, 'got schema object' );

  my $reqs = $schema->resultset('Request');
  ok( defined $reqs, 'got some reqs resultset' );

TODO: {
  local $TODO = 'Need to re-engineer mail receive';

  my $req = $reqs->create( { channel_id => 1 } );
  my $hash = $req->hash;

  # run a file through email_receive.pl and make sure stuff goes
  # into the database
  system ("cat testdata/email_multiple_image.mail | sed 's/%%HASH%%/$hash/g' | bin/email_receive.pl");
  system ("bin/email_process.pl");

  # after that there should be four files with this request id
  my $files = $schema->resultset('File')->search(
   { 'request.id' => $req->id },
   { join => [ qw/ request / ] } 
  );

  ok (scalar $files->all == 4, '4 results');
};
