use strict;
use warnings;
use Test::More tests => 6;

use File::Temp qw/tempfile/;

use CollabIRCate::Config;

my $schema   = CollabIRCate::Config->schema;
my $template = "TESTXXXXXXXXXX";

ok( defined $schema, 'got schema object' );

my $files = $schema->resultset('File');
ok( defined $files, 'got some File resultset' );

# test storing some files
{
    my ( $fh, $filename ) = tempfile($template);
    rename $filename, "$filename.txt";
    $filename .= ".txt";

    my $files = $schema->resultset('File');
    my $file = $files->create( { filename => $filename, } );

    ok( defined $file->id && $file->id > 0, 'got a good file id, from file' );
    unlink($filename);
}

SKIP: {
    skip "mime types for filehandles not handled yet", 1;

    my ( $fh, $filename ) = tempfile($template);
    rename $filename, "$filename.txt";
    $filename .= ".txt";

    my $files = $schema->resultset('File');
    my $file = $files->create( { filename => $fh, } );

    ok( defined $file->id && $file->id > 0,
        'got a good file id, from filehandle'
    );

}

# test getting a files content back
{
    my ( $fh, $filename ) = tempfile($template);
    rename $filename, "$filename.txt";
    $filename .= ".txt";
    print $fh "abc123\n";
    close $fh;

    my $files = $schema->resultset('File');
    my $file = $files->create( { filename => $filename, } );

    ok( defined $file->id && $file->id > 0, 'got a good file id, from file' );
    unlink($filename);

    my $fh_back = $file->fh;

    my $data    = <$fh_back>;
    ok( $data =~ /abc123/, 'got data back, via fh' );
}

