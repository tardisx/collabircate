package CollabIRCate::Config;

=head1 NAME

CollabIRCate::Config - fetch configuraton for the CollabIRCate system

=head2 SYNOPSIS

  use CollabIRCate::Config;

  my $config = CollabIRCate::Config->config();
  my $name   = $config->{irc_server_name};

=cut

use strict;
use warnings;

use Config::Any;

=head2 config

Returns a hashref containing the configuration data for the CollabIRCate system. Reads the 
C<collabircate.conf> file. If the environment variable C<COLLABIRCATE_CONFIG_SUFFIX> is
set, then that suffix is appended to the config name (generally used only for testing).

You can override any config key by setting an appropriate environment variable. For instance,
to override the key C<server_name>, set the environment variable C<COLLABIRCATE_CONFIG_SERVER_NAME>
to the desired value.

=cut

sub config {
    my $filename = "collabircate.conf";
    $filename .= $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} || '';
    my $configs = Config::Any->load_files(
        {   files         => [$filename],
            use_ext       => 1,
            force_plugins => ['Config::Any::General']
        }
    );
    my $config = $configs->[0]->{$filename};

    # override with any env settings
    foreach my $env ( keys %ENV ) {
      next unless ($env =~ /^COLLABIRCATE_CONFIG_(\w+)$/);
      $config->{lc($1)} = $ENV{$env};
    }

    return $config;
}

=head2 plugin_enabled

Determine if a plugin is enabled.

  if (CollabIRCate::Config->plugin_enabled('hailo')) {
    warn "Hailo plugin is enabled!";
  }

=cut

sub plugin_enabled {
    my $class       = shift;
    my $plugin_name = shift;
    my $config      = config();

    $plugin_name =~ s/^CollabIRCate::Bot:://;
    $plugin_name =~ s/::/_/g;
    $plugin_name = lc($plugin_name);

    if ( defined $config->{ "$plugin_name" . "_enabled" } ) {
        return $config->{ "$plugin_name" . "_enabled" };
    }
    return 1;    # assume enabled
}

=head2 http_root 

Convenience method to assemble the full base http address of the web interface from
various config variables.

  my $url = CollabIRCate::Config->http_root(); # http://localhost:3000 

=cut

sub http_root {
    my $output = "http://";
    $output .= config()->{http_server_host};
    $output .= ":" . config()->{http_server_port}
        if ( config()->{http_server_port} );
    return $output;
}

1;
