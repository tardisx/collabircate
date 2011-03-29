package CollabIRCate::DB::Nick;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'irc_nick',

    columns => [
        id          => { type => 'serial',    not_null => 1, primary_key => 1 },
        nick        => { type => 'text',      not_null => 1 },
        irc_user_id => { type => 'integer',   not_null => 1 },
        ts          => { type => 'timestamp', not_null => 1 },
    ],

    foreign_keys => [
        irc_user => {
            class       => 'CollabIRCate::DB::IRCUser',
            key_columns => { irc_user_id => 'id' },
        },
    ],
);

1;
