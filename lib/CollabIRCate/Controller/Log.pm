package CollabIRCate::Controller::Log;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use DateTime;

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
    $c->stash( channel => $channel );

    $channel = "#" . $channel;
    my $logs
        = $c->model('CollabIRCateDB::Log')
        ->search( { 'channel.name' => $channel },
        { join => [qw/ channel users /], order_by => 'ts' } );

    $c->stash( logs    => $logs );
}

sub latest : Chained('channel_setup') PathPart('latest') : Args(0) {
    my ( $self, $c ) = @_;

    # redirect to the place we need to be
    
    my $channel = $c->stash->{'channel'};
    my $start = DateTime->now->date;
    $start =~ s#-#/#g;

    $c->res->redirect($c->uri_for("/log/channel/$channel/date/" . $start . '#bottom'));
    $c->detach();

}

sub date : Chained('channel_setup') PathPart('date') : Args(3) {
    my ( $self, $c, $year, $month, $day ) = @_;

    my $logs = $c->stash->{logs};
    my $date =    sprintf "%04d-%02d-%02d", $year, $month, $day;
    my $date_to = sprintf "%04d-%02d-%02d", $year, $month, $day+1;


    warn "FROM: $date TO: $date_to";

    $logs = $logs->search( { ts => { '>=', $date, '<', $date_to } } );
    $c->stash( logs     => [ $logs->all ] );
    $c->stash( template => 'log/latest' );

}

sub end : Private {
    my ( $self, $c ) = @_;

    warn "in end";
    $c->forward('CollabIRCate::View::Site');
}

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
