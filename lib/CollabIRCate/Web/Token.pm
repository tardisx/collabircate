package CollabIRCate::Web::Token;

use strict;
use warnings;

use Carp qw/croak/;

use base 'Mojolicious::Controller';

use CollabIRCate::DB::User;
use CollabIRCate::DB::User::Manager;
use CollabIRCate::DB::Token;
use CollabIRCate::Bot::Users;

# Deal with logins (and logouts)
sub index {
    my $self = shift;
    my $token = $self->stash->{token};
    my $message;

    if (! $self->stash->{session}->{logged_in}) {
      $self->stash->{message} = 'you need to login first';
      return;
    }

    my $tokendb;
    eval {
      $tokendb = CollabIRCate::DB::Token->new(token=>$token)->load;
    };

    if ($@ || ! $tokendb) {
      $self->stash->{message} = 'invalid token';
      return;
    }

    # ok we have a token - grab the data
    my $data = $tokendb->data;

    # are we logged in?
    my $username = $self->stash->{session}->{logged_in};

    # link these bastards
    my $buser = CollabIRCate::Bot::Users->from_ircuser('xxx', #fake nick
                                                       split /!/, $data);
    $buser->link($username);
    $self->stash->{message} = 'ok - session linked to you';

}

1;
