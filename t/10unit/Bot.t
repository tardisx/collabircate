use strict;
use warnings;
use Test::More tests => 30;

BEGIN {
    $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} = '.sample';
    use_ok 'CollabIRCate::Bot';
    use_ok 'CollabIRCate::Bot::Users';
}

use CollabIRCate::Bot;
my $bot = CollabIRCate::Bot->new();

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# general
# simulate fred saying hello (not on channel)
my $response = $bot->bot_addressed( $user, undef, 'hello' );
ok( defined $response && ! $response->has_response, 'empty response' );

# simulate fred saying hello (on channel)
$response = $bot->bot_addressed( $user, '#foobar', 'hello' );
ok( defined $response && ! $response->has_response, 'empty response' );

# do some math

# privately
$response = $bot->bot_addressed( $user, undef, 'what is 2+2?' );
# first response, text part
ok( $response->private_response->[0]->[1] =~ /4/, 'adds privately' );

$response = $bot->bot_addressed( $user, undef, 'what is 1/0?' );
# first response, text part
ok( $response->private_response->[0]->[1] =~ /nice try/, 'refuses divide by zero, privately' );

# publically, indirectly and directly
$response = $bot->bot_heard( $user, '#testchannel', 'what is 2+9?' );
ok( $response->public_response->[0]->[1] =~ /11/, 'adds publically, indirectly' );

$response = $bot->bot_addressed( $user, '#testchannel', 'what is 2+10?' );
ok( $response->public_response->[0]->[1] =~ /12/, 'adds publically, directly' );

# world time
$response = $bot->bot_addressed( $user, undef, 'london time?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #1' );
$response = $bot->bot_addressed( $user, undef, 'time in london?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #2' );
$response = $bot->bot_addressed( $user, undef, 'what is the time in london?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #3' );
$response = $bot->bot_addressed( $user, undef, 'time in london?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #4' );
$response = $bot->bot_addressed( $user, undef, 'what is the time in london now?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #3' );
$response = $bot->bot_addressed( $user, undef, 'what is the time in timbuctoo now?' );
ok( $response->private_response->[0]->[1] =~ /sorry/, 'unknown place' );

# not world time
foreach my $test ('he should talk shit up, big time',
                  'this is not the time or the place',
                  'anytime is good for me',
                 ) {

  $response = $bot->bot_addressed( $user, undef, $test);
  ok( !defined $response->private_response, 'not really a time request: '.$test);
}

TODO: {
  local $TODO = 'maybe this will be a special case one day...';

  $response = $bot->bot_addressed( $user, undef, 'what time?');
  ok( !defined $response->private_response, 'not really a time request: what time?');
}

# linking
foreach my $test ('link me',
                  'link me please',
                  'link me up',
                  'link') {
  $response = $bot->bot_addressed( $user, '#testchannel', $test );
  ok ( defined $response->private_response &&  $response->private_response->[0]->[1] =~ m|token/link/[0-9a-f]{32}$|, 'has a token: '.$test );
  ok ( ! defined $response->public_response || ! defined $response->public_response->[0], 'no public response: '.$test );
}

# upload token
foreach my $test ('upload',
                  'upload token') {
  $response = $bot->bot_addressed( $user, '#testchannel', $test );
  ok ( defined $response->private_response &&  $response->private_response->[0]->[1] =~ m|token/upload/[0-9a-f]{32}$|, 'has a token: '.$test );
  ok ( ! defined $response->public_response || ! defined $response->public_response->[0], 'no public response: '.$test );
}
