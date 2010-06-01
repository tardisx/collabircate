#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 11;
use Test::Mojo;

use_ok('CollabIRCate::Web');

# Test /
my $t = Test::Mojo->new(app => 'CollabIRCate::Web');
$t->post_form_ok('/user/login', {username => 'foo', password => 'bar', submit => 1})
  ->status_is(200)
  ->content_type_is('text/html')
  ->content_like(qr/login success/i)
  ->content_like(qr/logged in as foo/i)

  ->get_ok('/user/logout')
  ->status_is(200)
  ->content_type_is('text/html')
  ->content_like(qr/now logged out/i)
  ->content_like(qr/Not logged in/i);
