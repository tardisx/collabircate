package CollabIRCate::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
    "id",
    {   data_type => "integer",

        #    default_value => "nextval('users_id_seq'::regclass)",
        is_nullable => 0,
        size        => 4,
    },
    "email",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "password",
    {   data_type     => "text",
        default_value => undef,
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "users_pkey", ["id"] );
__PACKAGE__->has_many(
    "channel_reports",
    "CollabIRCate::Schema::ChannelReport",
    { "foreign.users_id" => "self.id" },
);
__PACKAGE__->has_many( "logs", "CollabIRCate::Schema::Log",
    { "foreign.users_id" => "self.id" },
);

1;
