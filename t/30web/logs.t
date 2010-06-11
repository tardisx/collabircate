#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 35;
use Test::Mojo;
use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Bot::Users;

my $user = CollabIRCate::Bot::Users->from_ircuser( 'testguy1', 'testguyuser', 'some.machine.somewhere' );
my $channel = '#webtest'.$$;

foreach (1..10) {
  my $msg = "test$_";
  ok (add_log( $user, $channel, 'log', $msg ), "added log $_");
}

ok (add_log( $user, $channel, 'topic', 'this is a test'), "added topic log");
ok (add_log( $user, $channel, 'part', 'bored'), "added part log");
ok (add_log( $user, $channel, 'join', 'joined'), "added join log");

use_ok('CollabIRCate::Web');

# Test channel list
my $t = Test::Mojo->new(app => 'CollabIRCate::Web');
$t->get_ok('/channels/')
  ->status_is(200)
  ->content_type_is('text/html')
  ->content_like(qr/webtest$$/)

# now the channel    
  ->get_ok('/channels/webtest'.$$)
  ->status_is(200)
  ->content_type_is('text/html')
  ->content_like(qr/test1/)
  ->content_like(qr/test2/)
  ->content_like(qr/test3/)
  ->content_like(qr/test4/)
  ->content_like(qr/test5/)
  ->content_like(qr/test6/)
  ->content_like(qr/test7/)
  ->content_like(qr/test8/)
  ->content_like(qr/test9/)
  ->content_like(qr/test10/)

  ->content_like(qr/joined/)
  ->content_like(qr/left/)
  ->content_like(qr/changed the topic/)
  ->content_like(qr/this is a test/);
