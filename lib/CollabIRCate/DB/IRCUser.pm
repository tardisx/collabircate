package CollabIRCate::DB::IRCUser;

use strict;
use warnings;

use Carp qw/croak/;
use CollabIRCate::DB::Nick;
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
        nicks       => {
            type       => 'one to many',
            class      => 'CollabIRCate::DB::Nick',
            column_map => { id => 'irc_user_id' },
            manager_args => { 
                sort_by => CollabIRCate::DB::Nick->meta->table.'.ts',
            },
        },
    ],
);

    
1;
