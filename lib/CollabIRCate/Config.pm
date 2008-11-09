package CollabIRCate::Config;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Config::General;
use CollabIRCate::Schema;

our $config;
our $schema;

sub config {

    $config = { Config::General->new("$Bin/../collabircate.conf")->getall }
        unless defined $config;

    return $config;

}

sub schema {

    return $schema if ( defined $schema );

    $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
        || die $!;

    return $schema;

}

1;
