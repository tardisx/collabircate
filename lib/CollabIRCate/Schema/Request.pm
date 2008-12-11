package CollabIRCate::Schema::Request;

use strict;
use warnings;
use Carp qw/croak/;

use Time::HiRes;
use Digest::MD5 qw/md5_hex/;

use CollabIRCate::Config;
my $config = CollabIRCate::Config->config();

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table("request");
__PACKAGE__->add_columns(
    "id",
    {   data_type   => "integer",
        is_nullable => 0,
        size        => 4,
    },
    "ts",
    {   data_type     => "datetime",
        default_value => undef,
        is_nullable   => 1,
        size          => undef,
    },
    "hash",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "user_id",
    {   data_type     => "integer",
        default_value => undef,
        is_nullable   => 1,
        size          => 4,
    },
    "channel_id",
    {   data_type     => "integer",
        default_value => undef,
        is_nullable   => 1,
        size          => 4,
    },
    "file_id",
    {   data_type     => "integer",
        default_value => undef,
        is_nullable   => 1,
        size          => 4,
    },
    "logged", 
    {   data_type     => "boolean",
        default_value => 'f',
        is_nullable   => 0,
    }
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "request_pkey", ["id"] );
__PACKAGE__->belongs_to( "users", "CollabIRCate::Schema::Users",
    { id => "users_id" },
);
__PACKAGE__->belongs_to(
    "users",
    "CollabIRCate::Schema::Channel",
    { id => "channel_id" },
);
__PACKAGE__->belongs_to( "users", "CollabIRCate::Schema::File",
    { id => "file_id" },
);

sub insert {
    my ( $self, @args ) = @_;

    my $hash_text = Time::HiRes::time() . $$ . rand( time() );
    my $hash_md5  = md5_hex($hash_text);

    $self->hash($hash_md5);

    $self->next::method(@args);

    return $self;
}


sub url {
    my $self = shift;
    my $hash = $self->hash;

    my $url = $config->{upload_url};

    croak "No upload_url set in config" unless $url;

    $url =~ s/HASH/$hash/;

    return $url;
}

sub email {
    my $self  = shift;
    my $hash = $self->hash;

    my $email = $config->{upload_email};

    croak "No upload_email set in config" unless $email;

    $email =~ s/HASH/$hash/;

    return $email;
}

__END__

=head1 NAME

CollabIRCate::Schema::Request - Deals with requests to upload files

=head1 SYNOPSIS

  my $set = $schema->resultset('Request');
  my $req = $schema->create ( { user_id => $uid } );

  my $id = $req->id;
  my $hash = $req->hash;

=cut
