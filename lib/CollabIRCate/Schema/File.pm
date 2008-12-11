package CollabIRCate::Schema::File;

use strict;
use warnings;
use Carp qw/croak/;

use File::Temp;
use File::Copy qw/copy/;
use MIME::Types;

use CollabIRCate::Config;
my $config = CollabIRCate::Config->config();

my $store_path = $config->{file_store_path}
    || croak "file_store_path not defined in config";

croak "nowhere to store files - '$store_path' does not exist"
    unless -d $store_path;

our %tmp_filenames;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table("file");
__PACKAGE__->add_columns(
    "id",
    {   data_type   => "integer",
        is_nullable => 0,
        size        => 4,
    },
    "filename",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 1,
        size          => undef,
    },
    "size",
    {   data_type     => "integer",
        is_nullable   => 0,
        size          => 4,
    },
    "mime_type",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "request_id",
    {   data_type     => "integer",
        is_nullable   => 1,
        sixe          => 4,
    }

);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "file_pkey", ["id"] );
__PACKAGE__->belongs_to(
    "request",
    "CollabIRCate::Schema::Request",
    { id => "request_id" },
);


sub new {
    my ( $class, $attrs ) = @_;

    croak "no such file " . $attrs->{filename}
        unless ( -e $attrs->{filename} );

    if ( !ref $attrs->{filename} ) {
        my $mime = MIME::Types->new();
        my $type = $mime->mimeTypeOf( $attrs->{filename} );
        $attrs->{mime_type} = $type;
        $attrs->{size}      = -s $attrs->{filename};
    }
    else {
        croak "don't know how to get mime type for filehandles yet";
    }

    my $template = "$store_path/importXXXXXXXXXXX";
    my $fh       = File::Temp->new( TEMPLATE => $template, UNLINK => 0 );
    my $filename = $fh->filename;

    copy( $attrs->{filename}, $fh ) || croak $!;
    close $fh || croak $!;

    my $new = $class->next::method($attrs);
    $tmp_filenames{$new} = $filename;

    return $new;
}

sub insert {
    my ( $self, @args ) = @_;
    $self->next::method(@args);

    my $mime   = MIME::Types->new();
    my $type   = $self->mime_type;
    my $dest = _filename($self->id);
    
    croak "file '$dest' already exists!" if -e $dest;
    rename $tmp_filenames{$self}, $dest;
    delete $tmp_filenames{$self};
    return $self;
}


sub fh {
    my ( $self ) = shift;
    my $id = $self->id;

    my $fh;
    open ($fh, "<", _filename($id)) || croak "could not open " . _filename($id);
    return $fh;
}

sub _hash_dir {
    my $id = shift;
    my $i  = $id % 10;
    my $j  = ( $id / 10 ) % 10;

    unless ( -d "$store_path/$j" ) {
        mkdir "$store_path/$j" || croak "could not mkdir: $!";
    }
    unless ( -d "$store_path/$j/$i" ) {
        mkdir "$store_path/$j/$i" || croak "could not mkdir: $!";
    }

    return "$store_path/$j/$i";
}

sub _filename {
    my $id = shift;
    return sprintf( "%s/%08d", _hash_dir( $id ), $id );
}
    
1;

__END__

=head1 NAME

CollabIRCate::Schema::File - Deal with files in the CollabIRCate system

=head1 SYNOPSIS

  my $set = $schema->resultset('File');
  my $file = $schema->create ( { filename => '/tmp/somefile.txt' } );

  my $id = $file->id;

=cut
