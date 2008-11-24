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

our %tmp_filenames;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ PK::Auto Core/);
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
    "mime_type",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },

);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "file_pkey", ["id"] );
#__PACKAGE__->has_many(
#    "channel_reports",
#    "CollabIRCate::Schema::ChannelReport",
#    { "foreign.channel_id" => "self.id" },
#);
#__PACKAGE__->has_many( "logs", "CollabIRCate::Schema::Log",
#    { "foreign.channel_id" => "self.id" },
#);

sub new {
    my ( $class, $attrs ) = @_;

    croak "no such file " . $attrs->{filename} unless (-e $attrs->{filename});

    my $mime = MIME::Types->new();
    my $type = $mime->mimeTypeOf($attrs->{filename});
    $attrs->{mime_type} = $type;

    my $template = "$store_path/importXXXXXXXXXXX";
    my $fh = File::Temp->new(TEMPLATE => $template, UNLINK => 0);
    my $filename = $fh->filename;

    copy ($attrs->{filename}, $fh) || croak $!;
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
    my $suffix = ( $mime->type($type)->extensions )[0];
    my $dest   = sprintf( "%s/%08d.%s", $store_path, $self->id, $suffix );

    croak "file '$dest' already exists!" if -e $dest;
    rename $tmp_filenames{$self}, $dest;
    delete $tmp_filenames{$self};
    return $self;
}

1;
