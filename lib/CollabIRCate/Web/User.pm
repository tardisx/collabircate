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

        my $users = CollabIRCate::DB::User::Manager->get_users(
            query => [ username => $username, password => $password ]
        );
        
        if ($users && $users->[0]) {
            $self->stash->{message} = 'login success';
            $self->stash->{session}->{logged_in} = $username;
            if ($form->param('return')) {
              $self->stash->{return} = $form->param('return');
            }
        }
        else {
            $self->stash->{message} = 'login failure';
            $self->stash->{session}->{logged_in} = undef;
        }
    }

    $self->stash->{form} = $form;    
}

sub logout {
    my $self = shift;
    
    $self->stash->{session}->{logged_in} = undef;
}

1;
