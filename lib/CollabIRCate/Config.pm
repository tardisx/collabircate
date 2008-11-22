package CollabIRCate::Config;

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Config::General;
use Carp qw/croak/;

use CollabIRCate::Schema;

our $config;
our $schema;

sub config {

    $config = { Config::General->new("$Bin/../collabircate.conf")->getall }
        unless defined $config;

    croak "cannot load config file" unless defined $config;

    return $config;

}

sub schema {

    return $schema if ( defined $schema );
    my $config = config();
    
    $schema = CollabIRCate::Schema->connect($config->{dsn})
        || croak "cannot connect to schema";

    return $schema;

}

1;
