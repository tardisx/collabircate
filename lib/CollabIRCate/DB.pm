package CollabIRCate::DB;

use strict;
use warnings;

use Rose::DB;
use base 'Rose::DB';

use CollabIRCate::Config;

=head1 NAME

CollabIRCate::DB

=head1 DESCRIPTION

Provide DB connectivity to the CollabIRCate system.

See L<Rose::DB> for details.

=cut

my $config = CollabIRCate::Config->config();

# Use a private registry for this class
__PACKAGE__->use_private_registry;

# Set the default domain and type
__PACKAGE__->default_domain($config->{database_domain} || 'development');
__PACKAGE__->default_type($config->{database_type} || 'sqlite');

# Register the data sources

# Development:
__PACKAGE__->register_db(
  domain   => 'development',
  type     => 'sqlite',
  driver   => 'SQLite',
  database => 'collabircate_dev.db',
);

# XXX TODO remove hard coded username/password
# Development (Pg):
__PACKAGE__->register_db(
  domain   => 'development',
  type     => 'pg',
  driver   => 'pg',
  database => 'collabircate_dev',
  host     => 'localhost',
  username => 'justin',
  password => 'justin',
);

# Production:
__PACKAGE__->register_db(
  domain   => 'production',
  driver   => 'pg',
  database => 'collabircate',
  host     => 'localhost',
  username => 'justin',
  password => 'justin',
);


1;
