#!/usr/bin/perl

use Pod::ProjectDocs;

use strict;
use warnings;

my $pd = Pod::ProjectDocs->new(
  outroot => 'doc/',
  libroot => 'lib/',
  title   => 'CollabIRCate',
  desc    => 'CollabIRCate is a free, open-source collaboration tool',
);
$pd->gen();
