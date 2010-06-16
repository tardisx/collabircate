package CollabIRCate::Config;

use strict;
use warnings;

use Config::Any;

sub config {
    my $filename = "collabircate.conf";
    $filename .= $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} || ''; 
    my $configs = Config::Any->load_files({files => [$filename], use_ext => 1, force_plugins=>['Config::Any::General']});
    my $config = $configs->[0]->{$filename};

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

sub http_root {
    my $output = "";
    $output = config()->{http_server_host};
    $output .= ":" . config()->{http_server_port} if (config()->{http_server_port});
    return $output;
}

1;
