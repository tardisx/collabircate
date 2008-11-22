package CollabIRCate::Schema::File;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ PK::Auto Core/);
__PACKAGE__->table("file");
__PACKAGE__->add_columns(
    "id",
    {   data_type   => "integer",
        is_nullable => 0,
        size        => 4,
    },
    "original_file",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 1,
        size          => undef,
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

1;
