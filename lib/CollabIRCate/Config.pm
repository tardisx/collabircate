package CollabIRCate::Config;

use strict;
use warnings;

use Config::Any;

sub config {
    my $configs = Config::Any->load_files({files => ["collabircate.conf"], use_ext => 1});
    my $config = $configs->[0]->{'collabircate.conf'};

    return $config;
}

sub plugin_enabled {
    my $class = shift;
    my $plugin_name = shift;
    my $config = config();
 
    $plugin_name =~ s/^CollabIRCate::Bot:://;
    $plugin_name =~ s/::/_/g;
    $plugin_name = lc ($plugin_name);

    if (defined $config->{"$plugin_name"."_enabled"}) {
      return $config->{"$plugin_name"."_enabled"};
    }
    return 1;  # assume enabled
}

1;
