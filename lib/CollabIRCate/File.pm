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
    my ( $files, $hash ) = @_;

    my @files;
    @files = @{$files} if ( ref($files) eq 'ARRAY' );
    @files = ($files) if ( !ref($files) );

    foreach (@files) {
        croak "no such file '$_'" unless -f $_;
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
        # tell the file where it came from
        $file->request_id($request->id);
        $file->update;
        push @file_ids, $file->id;
    }

    return (@file_ids);
    
}

