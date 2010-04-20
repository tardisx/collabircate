package CollabIRCate::DB::User;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'user',

    columns => [
        id          => { type => 'serial', not_null => 1, primary_key => 1 },
        email       => { type => 'text',   not_null => 0 },
    ],

    unique_key => 'email',

    relationships => [
        keywords => {
            type       => 'one to many',
            class      => 'CollabIRCate::DB::Log',
            column_map => { id => 'users_id' },
        },
    ],
);

1;
