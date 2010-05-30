package CollabIRCate::Web::User;

use strict;
use warnings;

use Carp qw/croak/;

use base 'Mojolicious::Controller';

use CollabIRCate::DB::User;
use CollabIRCate::DB::User::Manager;

# Deal with logins (and logouts)
sub login {
    my $self = shift;

    my $username = $self->req->param('username');
    my $password = $self->req->param('password');

    croak if (! $username || ! $password);

    my $users = CollabIRCate::DB::User::Manager->get_users(
        query => [ username => $username, password => $password ]
    );

    if ($users && $users->[0]) {
    
        # Render template "example/welcome.html.ep" with message
        $self->stash->{message} = 'hi you logged in '. $username;
        $self->stash->{session}->{logged_in} = $username;
    }
    else {
        $self->stash->{message} = 'you are so not logged in';
        $self->stash->{session}->{logged_in} = undef;
    }
}

sub logout {
    my $self = shift;

    $self->stash->{logged_in} = undef;
}

1;
