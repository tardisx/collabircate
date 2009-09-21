use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'CollabIRCate' }
BEGIN { use_ok 'CollabIRCate::Controller::REST' }

ok( request('/rest')->is_success, 'Request should succeed' );


