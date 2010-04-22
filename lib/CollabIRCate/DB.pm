package CollabIRCate::DB;

use strict;
use warnings;

use Rose::DB;
use base 'Rose::DB';

# Use a private registry for this class
__PACKAGE__->use_private_registry;

# Set the default domain and type
__PACKAGE__->default_domain('development');

# Register the data sources

# Development:
__PACKAGE__->register_db(
  domain   => 'development',
  driver   => 'SQLite',
  database => 'collabircate_dev.db',
);

# XXX TODO remove hard coded username/password
# Development (Pg):
__PACKAGE__->register_db(
  domain   => 'development_pg',
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
