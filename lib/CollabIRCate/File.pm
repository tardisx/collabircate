package CollabIRCate::File;

use strict;
use warnings;
use Carp;

require CollabIRCate::Config;
require CollabIRCate::Schema;

#require CollabIRCate::Schema::Channel;
#require CollabIRCate::Schema::Tag;

use Exporter qw/import/;
our @EXPORT_OK = qw/accept_file/;

our $config = CollabIRCate::Config->config();
our $schema = CollabIRCate::Config->schema();

# accept a file that has been sent to us, with a request hash

sub accept_file {
    my ( $files, $hash, $requested_filename ) = @_;

    my @files;
    @files = @{$files} if ( ref($files) eq 'ARRAY' );
    @files = ($files) if ( !ref($files) );

    foreach (@files) {
        croak "no such file '$_'" unless -f $_;
    }

    if (! @files) {
        croak "no files?";
    }
    
    if ((scalar @files > 1) && $requested_filename) {
        croak "can't have a requested_filename if passing multiple files"
    }
    
    # find the hash
    my $request
        = $schema->resultset('Request')->search( { hash => $hash } );
    $request = $request->first;
    croak "no such request '$hash'" unless $request;

    # which file id's did we create?
    my @file_ids = ();

    # store these files
    foreach (@files) {
        my $file = $schema->resultset('File')->create( { filename => $_ } );
        # tell the request what the file is
        $file->request_id($request->id);

        # change the filename, if requested
        $file->filename($requested_filename) if ($requested_filename);
        $file->set_mime_type_from_filename if ($requested_filename);

        $file->update;
        push @file_ids, $file->id;
    }

    return (@file_ids);
    
}

