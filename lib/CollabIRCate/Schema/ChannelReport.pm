package CollabIRCate::Schema::ChannelReport;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("channel_report");
__PACKAGE__->add_columns(
  "users_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "channel_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "report_expires",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "report_frequency",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "report_last",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("users_id", "channel_id");
__PACKAGE__->add_unique_constraint("channel_report_pkey", ["users_id", "channel_id"]);
__PACKAGE__->belongs_to(
  "users_id",
  "CollabIRCate::Schema::Users",
  { id => "users_id" },
);
__PACKAGE__->belongs_to(
  "channel_id",
  "CollabIRCate::Schema::Channel",
  { id => "channel_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-28 10:59:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Lr80P6sVyTBtr+sVsqILrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
