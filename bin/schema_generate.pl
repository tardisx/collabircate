#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

# use YAML qw/LoadFile/;

my $version = shift;
die unless $version;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));

my $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
  || die $!;

$schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
                        $version,
                        'etc/',
			);

