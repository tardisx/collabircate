package CollabIRCate::Schema::Log;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("log");
__PACKAGE__->add_columns(
  "log_id",
  {
    data_type => "integer",
    default_value => "nextval('log_log_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "ts",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 0,
    size => 8,
  },
  "channel_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "type",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "entry",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("log_id");
__PACKAGE__->add_unique_constraint("log_pkey", ["log_id"]);
__PACKAGE__->belongs_to(
  "channel_id",
  "CollabIRCate::Schema::Channel",
  { channel_id => "channel_id" },
);
__PACKAGE__->belongs_to(
  "user_id",
  "CollabIRCate::Schema::Users",
  { user_id => "user_id" },
);
__PACKAGE__->has_many(
  "tags",
  "CollabIRCate::Schema::Tag",
  { "foreign.log_id" => "self.log_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-21 11:43:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XSu4W/frc2NbR6VkKKbcmA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
