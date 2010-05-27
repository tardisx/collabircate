package CollabIRCate::DB::Log;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'log',

    columns => [
        id          => { type => 'serial', not_null => 1, primary_key => 1 },
        ts        => { type => 'timestamp',   not_null => 1 },
        channel_id => { type => 'integer', not_null => 1 },
        type      => { type => 'text', not_null => 1 },
        entry     => { type => 'text', not_null => 1 },
    ],

    foreign_keys =>
        [ channel => { class => 'CollabIRCate::DB::Channel',
                       key_columns => { channel_id => 'id' }, },
      ],
);

1;
