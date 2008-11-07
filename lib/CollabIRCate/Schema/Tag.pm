package CollabIRCate::Schema::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tag_id_seq'::regclass)",
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("tag_pkey", ["id"]);
__PACKAGE__->belongs_to("log_id", "CollabIRCate::Schema::Log", { id => "log_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-28 10:59:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I7pCJx6UDFNhxSHkm4P7UQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
