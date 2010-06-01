package CollabIRCate::Web::Channels;

use strict;
use warnings;

use Carp qw/croak/;

use CollabIRCate::DB::Channel::Manager;

use base 'Mojolicious::Controller';

sub list {
    my $self = shift;

    my $channels = CollabIRCate::DB::Channel::Manager->get_channels();

    $self->stash->{channels} = $channels;
}

sub show {
    my $self = shift;
    my $channel = $self->req->param('channel');

    my $channel_db = CollabIRCate::DB::Channel->new(name=>$channel)->load;

    
    
}

1;
