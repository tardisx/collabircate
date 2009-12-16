use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'CollabIRCate' }
BEGIN { use_ok 'CollabIRCate::Controller::Log' }

ok( request('/log/channel/people/latest')->is_redirect, '/latest should redirect');

