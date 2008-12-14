use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'CollabIRCate' }
BEGIN { use_ok 'CollabIRCate::Controller::File' }

ok( request('/file')->is_success, 'Request should succeed' );


