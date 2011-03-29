package CollabIRCate::Web::User;

use strict;
use warnings;

use Carp qw/croak/;

use base 'Mojolicious::Controller';

use CollabIRCate::DB::User;
use CollabIRCate::DB::User::Manager;

use HTML::FormFu;

# Deal with logins (and logouts)
sub login {
    my $self = shift;
    my $form = HTML::FormFu->new({action => "/user/login"});

    $self->stash->{message} = '';
    $self->stash->{return} = '';
    
    $form->load_config_file('forms/login.yml');
    $form->process($self->req->params->to_hash);

    my $hidden = $form->get_all_element( { name => 'return' } );
    $hidden->default( $self->req->param('return') );

    if ($form->submitted_and_valid) {
        my $username = $self->req->param('username');
        my $password = $self->req->param('password');

        croak if (! $username || ! $password);

        # XXX evil this needs to be hashed
        my $users = CollabIRCate::DB::User::Manager->get_users(
            query => [ username => $username, password => $password ]
        );
        
        if ($users && $users->[0]) {
            $self->stash->{message} = 'login success';
            $self->session->{logged_in} = $username;
            if ($form->param('return')) {
              $self->stash->{return} = $form->param('return');
            }
        }
        else {
            $self->stash->{message} = 'login failure';
            delete $self->session->{logged_in};
        }
    }

    $self->stash->{form} = $form;    
}

sub logout {
    my $self = shift;

    delete $self->session->{logged_in};
}

sub show {
    my $self = shift;
    
    my $users = CollabIRCate::DB::User::Manager->get_users(
      query => [ id => $self->param('uid') ],
    );
    # should be just one
    if (@$users == 0) {
       die "no such user";
    }
    if (@$users != 1) {
       die "huh? multiple users?";
    }
    $self->stash->{user} = $users->[0];
    $self->render();
    return;
}

1;
