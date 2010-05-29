package CollabIRCate::Web::User;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# Deal with logins (and logouts)
sub login {
    my $self = shift;

    # Render template "example/welcome.html.ep" with message
    $self->stash->{message} = 'hi';
}

sub logout {

}

1;
