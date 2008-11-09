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

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched CollabIRCate::Controller::Log in Log.');
}

sub channel_setup : Chained('/') PathPart('log/channel') CaptureArgs(1) {
    my ( $self, $c, $channel ) = @_;
    $channel = "#" . $channel;
    my $logs
        = $c->model('CollabIRCateDB::Log')
        ->search( { 'channel_id.name' => $channel },
        { join => [qw/ channel_id users_id /], order_by => 'ts' } );

    $c->stash( channel => $channel );
    $c->stash( logs    => $logs );
}

sub latest : Chained('channel_setup') PathPart('latest') : Args(0) {
    my ( $self, $c ) = @_;

    #    my $channel = $c->stash->{'channel'};
    my $logs = $c->stash->{logs};

    my $interval = "> now() - '65 minutes'::INTERVAL";

    $logs = $logs->search( { ts => \$interval } );

    $c->stash->{logs} = [ $logs->all ];

}

sub date : Chained('channel_setup') PathPart('date') : Args(1) {
    my ( $self, $c, $date ) = @_;

    my $logs = $c->stash->{logs};

    $logs = $logs->search( { ts => { '>', $date } } );
    $c->stash( logs     => [ $logs->all ] );
    $c->stash( template => 'log/latest' );

}

sub hour : Chained('date') PathPart('hour') : Args(1) {
    my ( $self, $c, $hour ) = @_;

    my $logs = $c->stash->{logs};

    die "OOH, but hour is now $hour";
}

sub end : Private {
    my ( $self, $c ) = @_;

    $c->forward('CollabIRCate::View::Site');
}

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
