package CollabIRCate::Model::CollabIRCateDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

require CollabIRCate::Config;

my $config = CollabIRCate::Config->config;

__PACKAGE__->config(
    schema_class => 'CollabIRCate::Schema',
    connect_info => [ $config->{dsn} ],
);

=head1 NAME

CollabIRCate::Model::CollabIRCateDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<CollabIRCate>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<CollabIRCate::Schema>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
