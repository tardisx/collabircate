package CollabIRCate::Config;

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Config::General;
use Carp qw/croak/;

use Config::General;

my  $config;
my  $schema;

sub config {

    return $config if defined $config;

    $config = { Config::General->new("$Bin/../collabircate.conf")->getall }
        unless defined $config;

    croak "cannot load config file" unless defined $config;

    # update config from ENV
    foreach my $key (keys %ENV) {
      next unless $key =~ m/^COLLABIRCATE_CONFIG_(\w+)$/;
      if (! defined $config->{lc $1}) {
        warn "unknown environment variable $key\n";
      }
      else {
        $config->{lc $1} = $ENV{$key};
      }
    }

    return $config;

}

sub schema {

    return $schema if ( defined $schema );
    my $config = config();

    # require this here to avoid a problem
    require CollabIRCate::Schema;
    
    $schema = CollabIRCate::Schema->connect($config->{dsn})
        || croak "cannot connect to schema";

    return $schema;

}

1;
