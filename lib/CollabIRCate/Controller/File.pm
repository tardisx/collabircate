package CollabIRCate::Controller::File;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use CollabIRCate::Config;
my $schema = CollabIRCate::Config->schema();

=head1 NAME

CollabIRCate::Controller::File - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched CollabIRCate::Controller::File in File.');
}

sub fetch : Path : Args(1) {
    my ( $self, $c, $id) = @_;

    my $file = $schema->resultset('File')->search({ id => $id});
    if ($file = $file->next) {
        $c->stash->{template} = undef;
        $c->response->content_type($file->mime_type);
        my $fh = $file->fh;

        # XXX this bites - got to be a better way to stream this out
        my $out;
        {
            local $/ = undef;
            $out = <$fh>;
        }
        $c->response->body($out);

    }
    else {
        die "unknown problem";
    }
    
}

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
