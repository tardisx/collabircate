#!/usr/bin/env perl

use Pod::ProjectDocs;

use strict;
use warnings;

my $pd = Pod::ProjectDocs->new(
  outroot => '../collabircate-docs/',
  libroot => ['lib/', 'doc/'],
  title   => 'CollabIRCate',
  desc    => 'CollabIRCate is a free, open-source collaboration tool',
  forcegen => 1,
);
$pd->gen();
