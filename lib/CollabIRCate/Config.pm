package CollabIRCate::Config;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Config::General;

our $config;

sub config {

    $config = { Config::General->new("$Bin/../collabircate.conf")->getall }
        unless defined $config;

    return $config;

}

1;
