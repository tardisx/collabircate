package CollabIRCate::DB::Log::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::Log' }

__PACKAGE__->make_manager_methods('logs');

1;

