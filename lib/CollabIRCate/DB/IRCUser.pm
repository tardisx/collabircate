package CollabIRCate::DB::IRCUser;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'irc_user',

    columns => [
        id          => { type => 'serial',    not_null => 1, primary_key => 1 },

        irc_user    => { type => 'text',      not_null => 1 },
        ts          => { type => 'timestamp', not_null => 1 },
        user_id     => { type => 'integer',  },
        
    ],

    foreign_keys => [
        user => { class => 'CollabIRCate::DB::User',
                  key_columns => { user_id => 'id' }, },
    ],
    
    relationships => [
        keywords => {
            type       => 'one to many',
            class      => 'CollabIRCate::DB::Log',
            column_map => { id => 'irc_user_id' },
        },
    ],
);

    
1;
