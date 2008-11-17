package CollabIRCate::Schema::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
#    default_value => "nextval('tag_id_seq'::regclass)",
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
__PACKAGE__->belongs_to("log", "CollabIRCate::Schema::Log", { id => "log_id" });


1;
