package CollabIRCate::Bot::Plugin;

use strict;
use warnings;

use Carp qw/croak/;

# base class for plugins

BEGIN {
}

sub answer { die "unimplemented answer()"; };

sub register {

    croak "abstract register called!";
}

1;
