package CollabIRCate::DB::IRCUser::Manager;

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

sub object_class { 'CollabIRCate::DB::IRCUser' }

__PACKAGE__->make_manager_methods('ircusers');

1;

