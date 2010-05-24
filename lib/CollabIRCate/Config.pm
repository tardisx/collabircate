package CollabIRCate::Config;

use strict;
use warnings;

use Config::Any;

sub config {
    my $configs = Config::Any->load_files({files => ["collabircate.conf"], use_ext => 1});
    my $config = $configs->[0]->{'collabircate.conf'};

    return $config;
}

1;
