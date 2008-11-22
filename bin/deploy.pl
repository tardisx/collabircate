#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use CollabIRCate::Config;

my $schema = CollabIRCate::Config->schema();

$schema->deploy;
