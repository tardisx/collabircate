package CollabIRCate::Schema::Channel;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("channel");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('channel_id_seq'::regclass)",
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("channel_pkey", ["id"]);
__PACKAGE__->has_many(
  "channel_reports",
  "CollabIRCate::Schema::ChannelReport",
  { "foreign.channel_id" => "self.id" },
);
__PACKAGE__->has_many(
  "logs",
  "CollabIRCate::Schema::Log",
  { "foreign.channel_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-28 10:59:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ln9Sy4wXCkgXC21ltqA9nQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
