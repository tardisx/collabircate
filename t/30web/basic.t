#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::Mojo;

use_ok('CollabIRCate::Web');

# Test /
my $t = Test::Mojo->new('CollabIRCate::Web');
$t->get_ok('/')->status_is(200)->content_type_like(qr/text\/html/)
  ->content_like(qr/Welcome/i);

# login
$t = Test::Mojo->new('CollabIRCate::Web');
$t->get_ok('/user/login')->status_is(200)->content_type_like(qr/text\/html/)
  ->content_like(qr/username/i)
  ->content_like(qr/password/i);

# logout
$t = Test::Mojo->new('CollabIRCate::Web');
$t->get_ok('/user/logout')->status_is(200)->content_type_like(qr/text\/html/)
  ->content_like(qr/logged out/i);
