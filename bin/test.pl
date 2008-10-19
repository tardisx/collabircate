#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir($Bin, '..', 'lib')->stringify;
# use YAML qw/LoadFile/;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));

my $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate') || dir $!;

my $channel = $schema->resultset('Channel')->create({ name => 'fred' });
