package CollabIRCate::DB::LogCombined::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::LogCombined' }

__PACKAGE__->make_manager_methods('logs');

1;

