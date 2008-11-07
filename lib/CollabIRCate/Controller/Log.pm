package CollabIRCate::Controller::Log;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

CollabIRCate::Controller::Log - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched CollabIRCate::Controller::Log in Log.');
}

sub channel_setup :Chained('/') PathPart('log') CaptureArgs(1) {
    my ( $self, $c, $channel) = @_;
    $c->stash(channel => "#$channel");
}

sub latest :Chained('channel_setup') PathPart('latest') :Args(0) {
    my ( $self, $c) = @_;

    my $channel = $c->stash->{'channel'};

    my $interval = "> now() - '24 hours'::INTERVAL";

    my $logs = $c->model('CollabIRCateDB::Log')->search(
							{ts => \$interval, channel_id => 1},
							{order_by => 'ts',
							 join => ['users_id', 'channel_id']},
						      );

    $c->stash->{logs} = [$logs->all];

}

sub end : Private {
    my ( $self, $c )  = @_;
    
    $c->forward('CollabIRCate::View::Site');
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
