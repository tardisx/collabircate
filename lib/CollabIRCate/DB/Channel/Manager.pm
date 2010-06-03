package CollabIRCate::DB::Channel::Manager;

=head1 CollabIRCate::DB::Channel::Manager

Methods to retrieve groups of L<CollabIRCate::DB::Channel> objects.

=cut

use strict;
use warnings;

use base qw(Rose::DB::Object::Manager);

=head2 object_class 

Tell L<Rose::DB::Object::Manager> that they are objects of 
L<CollabIRCate::DB::Channel>.

=cut

sub object_class { 'CollabIRCate::DB::Channel' }

__PACKAGE__->make_manager_methods('channels');

1;

