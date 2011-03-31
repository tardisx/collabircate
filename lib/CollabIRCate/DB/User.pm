package CollabIRCate::DB::User;

=head1 NAME

CollabIRCate::DB::User - database abstraction for users

=head1 DESCRIPTION

L<CollabIRCate::DB::User>s represent actual authenticated users of the system (as opposed
to transient users visiting an IRC channel).

=cut

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'user',

    columns => [
        id          => { type => 'serial', not_null => 1, primary_key => 1 },

        email       => { type => 'text',   not_null => 1, },
        username    => { type => 'text',   not_null => 1, },
        password    => { type => 'text',   not_null => 1 },
        
    ],

    # XXX needed? unique for username and email at DB level
    unique_key => [ 'username' ],

);

    
1;
