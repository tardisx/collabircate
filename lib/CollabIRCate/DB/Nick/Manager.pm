package CollabIRCate::DB::Nick::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::Nick' }

__PACKAGE__->make_manager_methods('nicks');

1;

