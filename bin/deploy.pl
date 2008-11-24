#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Carp qw/croak/;

use CollabIRCate::Config;

my $config = CollabIRCate::Config->config();
my $schema = CollabIRCate::Config->schema();


$schema->deploy;

my $file_store_path = $config->{file_store_path};
if (! -d $file_store_path) {
  mkdir $file_store_path || croak "could not mkdir $file_store_path: $!";
}
