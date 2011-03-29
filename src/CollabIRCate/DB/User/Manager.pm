package CollabIRCate::DB::User::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::User' }

__PACKAGE__->make_manager_methods('users');

1;

