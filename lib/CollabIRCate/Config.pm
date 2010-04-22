package CollabIRCate::Config;

use strict;
use warnings;

use Config::Any;

sub config {
    my $configs = Config::Any->load_files({files => ["collabircate.conf"]});
    my $config = $configs->[0]->{'collabircate.conf'};

    return $config;
}

1;
