package CollabIRCate::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

sub mail : Local : ActionClass('REST') { }

sub mail_PUT {
  my ( $self, $c ) = @_;

  # Return a 200 OK, with the data in entity
  # serialized in the body
  $self->status_ok(
    $c,
    entity => {
        some => 'data',
        foo  => 'is real bar-y',
    },
  );
}

=head1 NAME

CollabIRCate::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

=head1 AUTHOR

Justin Hawkins,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
