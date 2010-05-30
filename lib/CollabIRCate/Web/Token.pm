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

    warn "TOKEN is $token";

    my $tokendb = CollabIRCate::DB::Token->new(token=>$token)->load;
    warn $tokendb;

    # ok we have a token - grab the data
    my $data = $tokendb->data;

    # are we logged in?
    my $username = $self->stash->{session}->{logged_in};

    # link these bastards
    my $buser = CollabIRCate::Bot::Users->from_ircuser('xxx', #fake nick
                                                       split /!/, $data);
    $buser->link($username);
    
}

1;
