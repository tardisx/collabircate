package CollabIRCate::Schema::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "tag_id",
  {
    data_type => "integer",
    default_value => "nextval('tag_tag_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "log_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("tag_id");
__PACKAGE__->add_unique_constraint("tag_pkey", ["tag_id"]);
__PACKAGE__->belongs_to("log_id", "CollabIRCate::Schema::Log", { log_id => "log_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-16 07:24:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qpvR3Qlk4ZJh8UtA9cDc9w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
