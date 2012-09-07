use strict;
use warnings;
use Test::More tests => 19;
use Test::Mojo;

BEGIN {
    $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} = '.sample';
    use_ok 'CollabIRCate::Bot';
    use_ok 'CollabIRCate::Bot::Users';
}

use CollabIRCate::Bot;
my $bot = CollabIRCate::Bot->new();

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# upload token
my $response = $bot->bot_addressed( $user, '#testchannel', 'upload' );
ok ( defined $response->private_response &&  $response->private_response->[0]->[1] =~ m|token/upload/[0-9a-f]{32}$|, 'has a token' );

my $url =  $response->private_response->[0]->[1];
$url =~ s/.*http:/http:/;
$url =~ s{^http://.*?/}{/};

my $t = Test::Mojo->new('CollabIRCate::Web');
$t->get_ok($url)
  ->status_is(200)
  ->content_type_like(qr/text\/html/)
  # it should be telling us to login
  ->content_like(qr{/user/login\?return=}i);

# so login already!
$t->post_form_ok('/user/login', {username => 'foo', password => 'bar', submit => 1})
  ->status_is(200)
  ->content_type_like(qr/text\/html/)
  ->content_like(qr/login success/i)
  ->content_like(qr/logged in as foo/i);

# now we can upload?
$t->get_ok($url)
    ->status_is(200)
    ->content_type_like(qr/text\/html/)
    # it should say we are logged in
    ->content_like(qr/logged in as foo/i);

my $file = Mojo::Asset::File->new->add_chunk('lalala');
$t->post_form_ok($url,
  {submit => 1, upload => {file => $file, filename => 'xyz'}})->status_is(200)
  ->content_like(qr/uploaded xyz it is \d+/);
