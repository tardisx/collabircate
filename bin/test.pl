#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

# use YAML qw/LoadFile/;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

# my $config = LoadFile(file($Bin, '..', 'collabircate.conf'));

my $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
  || die $!;

foreach ( 10 .. 99 ) {
    my $channel = $schema->resultset('Channel')->create(
        {
            name        => '#channel' . $_,
            description => 'Channel ' . $_
        }
    );
    warn "Created " . $channel->channel_id;
}
