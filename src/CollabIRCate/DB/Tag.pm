package CollabIRCate::DB::Tag;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
  table => 'tag',

  columns => [
    id     => { type => 'serial', not_null => 1, primary_key => 1 },
    name   => { type => 'text',   not_null => 1 },
    log_id => { type => 'int',    not_null => 1 },
  ],
  foreign_keys => [
    channel => {
      class       => 'CollabIRCate::DB::Log',
      key_columns => { log_id => 'id' },
    },
  ],
);

1;
