package CollabIRCate::DB::Object;

use strict;
use warnings;

use CollabIRCate::DB;

use Rose::DB::Object::Helpers 'insert_or_update';


use base qw(Rose::DB::Object);

sub init_db { CollabIRCate::DB->new }

1;
