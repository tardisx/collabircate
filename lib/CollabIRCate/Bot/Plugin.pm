package CollabIRCate::Bot::Plugin;

use strict;
use warnings;

# base class for plugins

BEGIN {
  warn "__PACKAGE__ init\n";
}

sub answer { die "unimplemented answer() in __PACKAGE__"; };

1;
