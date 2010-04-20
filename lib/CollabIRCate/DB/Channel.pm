package CollabIRCate::DB::Channel;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'channel',

    columns => [
        id          => { type => 'serial', not_null => 1, primary_key => 1 },
        name        => { type => 'text',   not_null => 1 },
        description => { type => 'text',   not_null => 0 },
    ],

    unique_key => 'name',

    relationships => [
        keywords => {
            type       => 'one to many',
            class      => 'CollabIRCate::DB::Log',
            column_map => { id => 'channel_id' },
        },
    ],
);

1;
