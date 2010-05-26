use strict;
use warnings;
use Test::More tests => 12;

BEGIN {
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
$response = $bot->bot_addressed( $user, undef, 'what is the time in london?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #1' );
$response = $bot->bot_addressed( $user, undef, 'time in london?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #2' );
$response = $bot->bot_addressed( $user, undef, 'what is the time in london now?' );
ok( $response->private_response->[0]->[1] =~ /\d\d:\d\d:\d\d/, 'got some london time #3' );
$response = $bot->bot_addressed( $user, undef, 'what is the time in timbuctoo now?' );
ok( $response->private_response->[0]->[1] =~ /sorry/, 'unknown place' );
