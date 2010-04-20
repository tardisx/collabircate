package CollabIRCate::DB::Object;

use strict;
use warnings;

use CollabIRCate::DB;

use base qw(Rose::DB::Object);

sub init_db { CollabIRCate::DB->new }

1;
