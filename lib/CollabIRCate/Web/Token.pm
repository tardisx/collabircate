package CollabIRCate::Web::Token;

use strict;
use warnings;

use Carp qw/croak/;

use base 'Mojolicious::Controller';

use CollabIRCate::DB::User;
use CollabIRCate::DB::User::Manager;
use CollabIRCate::DB::Token;
use CollabIRCate::DB::File;
use CollabIRCate::Bot::Users;

use CollabIRCate::Logger;

use HTML::FormFu;
use File::Temp qw/tmpnam/;

my $logger = CollabIRCate::Logger->get(__PACKAGE__);

sub link {
    my $self  = shift;
    my $token = $self->stash->{token};
    my $message;

    if ( !$self->session('logged_in') ) {
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
    my $username = $self->session('logged_in');

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
    $self->stash->{message} = 'ok - you havve been authenticated';
}

sub upload {
    my $self = shift;
    my $form = HTML::FormFu->new({action => "/token/upload"});

    $form->load_config_file('forms/upload.yml');
    $form->process($self->req->params->to_hash);

    my $hidden = $form->get_all_element( { name => 'token' } );
    $hidden->default( $self->req->param('token') );

    if ($form->submitted_and_valid) {

        my $size =   $self->req->upload('upload')->size;
        my $filename = $self->req->upload('upload')->filename;

        my $tmpfile = tmpnam();
        $self->req->upload('upload')->move_to($tmpfile);

        my $file = CollabIRCate::DB::File->new_from_file($tmpfile, 1, 1, $filename);
        $self->stash->{message} = "uploaded $filename it is " . $file->id;
        unlink $tmpfile;
    }
    else {
        $self->stash->{message} = 'hi';
    }
    $self->stash->{form} = $form;

}

1;
