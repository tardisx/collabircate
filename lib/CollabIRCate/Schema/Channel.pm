package CollabIRCate::Schema::Channel;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("channel");
__PACKAGE__->add_columns(
  "channel_id",
  {
    data_type => "integer",
    default_value => "nextval('channel_channel_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "description",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("channel_id");
__PACKAGE__->add_unique_constraint("channel_pkey", ["channel_id"]);
__PACKAGE__->has_many(
  "channel_reports",
  "CollabIRCate::Schema::ChannelReport",
  { "foreign.channel_id" => "self.channel_id" },
);
__PACKAGE__->has_many(
  "logs",
  "CollabIRCate::Schema::Log",
  { "foreign.channel_id" => "self.channel_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-16 07:24:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LLGqOkHZanLOCF15HerEtQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
