#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 21;
use Test::Mojo;

use_ok('CollabIRCate::Web');

# Test bad urls 404
my $t = Test::Mojo->new('CollabIRCate::Web');
$t->get_ok('/bad_url_here')
  ->status_is(404)->content_type_like(qr/text\/html/)
  ->content_like(qr/not found/i)

  ->get_ok('/bad/url/here/with/paths')
  ->status_is(404)->content_type_like(qr/text\/html/)
  ->content_like(qr/not found/i)

  ->get_ok('/bad/url/here/with/paths_and_extension.html')
  ->status_is(404)->content_type_like(qr/text\/html/)
  ->content_like(qr/not found/i)

  ->get_ok('/bad/url/here/with/paths_and_extension.jpg')
  ->status_is(404)->content_type_like(qr/text\/html/)
  ->content_like(qr/not found/i)

  ->get_ok('/bad/url/here/with/weird_name/.jpg')
  ->status_is(404)->content_type_like(qr/text\/html/)
  ->content_like(qr/not found/i);
