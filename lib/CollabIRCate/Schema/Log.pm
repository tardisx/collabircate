package CollabIRCate::Schema::Log;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("log");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('log_id_seq'::regclass)",
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
  "users_id",
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("log_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "users",
  "CollabIRCate::Schema::Users",
  { id => "users_id" },
);
__PACKAGE__->belongs_to(
  "channel",
  "CollabIRCate::Schema::Channel",
  { id => "channel_id" },
);
__PACKAGE__->has_many(
  "tags",
  "CollabIRCate::Schema::Tag",
  { "foreign.log_id" => "self.id" },
);


sub nice_ts {
    my $self = shift;
    my $ts   = $self->ts;
    $ts =~ s/\d\d\d\d\-\d\d\-\d\d\s(\d\d:\d\d).*/$1/;
    return $ts;
}

1;
