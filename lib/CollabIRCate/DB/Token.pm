package CollabIRCate::DB::Token;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'user',

    columns => [
        token   => { type => 'text',      not_null => 1, primary_key => 1 },
        expires => { type => 'timestamp', not_null => 1 },
        data    => { type => 'text',      not_null => 1 },
    ],
);

1;
