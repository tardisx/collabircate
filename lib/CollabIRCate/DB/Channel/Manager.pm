package CollabIRCate::DB::Channel::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::Channel' }

__PACKAGE__->make_manager_methods('channels');

1;

