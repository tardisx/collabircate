package CollabIRCate::Web::Token;

use strict;
use warnings;

use Carp qw/croak/;

use base 'Mojolicious::Controller';

use CollabIRCate::DB::User;
use CollabIRCate::DB::User::Manager;
use CollabIRCate::DB::Token;
use CollabIRCate::Bot::Users;

use CollabIRCate::Logger;

my $logger = CollabIRCate::Logger->get(__PACKAGE__);

sub link {
    my $self  = shift;
    my $token = $self->stash->{token};
    my $message;

    if ( !$self->stash->{session}->{logged_in} ) {
        $self->stash->{message} = 'you need to login first';
        return;
    }

    my $tokendb;
    eval {
        $tokendb
            = CollabIRCate::DB::Token->new( token => $token, type => 'link' )
            ->load;
    };

    if ( $@ || !$tokendb ) {
        $self->stash->{message} = 'invalid token';
        $logger->error("token '$token' is invalid");
        return;
    }

    # ok we have a token - grab the data
    my $data = $tokendb->data;

    # are we logged in?
    my $username = $self->stash->{session}->{logged_in};

    # link these bastards
    my $buser = CollabIRCate::Bot::Users->from_ircuser(
        'xxx',    # fake nick
        split /!/, $data
    );

    eval { $buser->link($username); };
    if ($@) {
        if ( $@ =~ /already linked/ ) {
            $self->stash->{message} = 'you are already linked!';
            return;
        }
        else {
            $logger->error("got $@ when trying to link");
            return;
        }
    }
    $self->stash->{message} = 'ok - session linked to you';
}

sub upload {
    my $self = shift;
    die "unimplemented";
}

1;
