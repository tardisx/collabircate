use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    use_ok 'CollabIRCate::Bot';
    use_ok 'CollabIRCate::Bot::Users';
}

use CollabIRCate::Bot qw/bot_addressed/;

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# general
# simulate fred saying hello (not on channel)
my $response = bot_addressed( $user, undef, 'hello' ); 
ok( defined $response && ! $response->has_response, 'empty response' );

# simulate fred saying hello (on channel)
my $response = bot_addressed( $user, '#foobar', 'hello' ); 
ok( defined $response && ! $response->has_response, 'empty response' );

# do some math
$response = bot_addressed( $user, undef, 'what is 2+2?' );
# first response, text part
ok( $response->private_response->[0]->[1] =~ /4/, 'adds 2+2' );

exit;

$response = bot_addressed( { from => 'fred', question => 'what is 1/0' } );
ok( $response->[0] =~ /nice try/i, 'refuses to divide by zero' );

$response = bot_addressed( { from => 'fred', question => 'no math here!' } );
ok( length $response->[0] > 5, 'responds to no math' ); # he'll say something!

# fml
$response = bot_addressed( { from => 'fred', question => 'fml' } );
ok( $response->[0] =~ /^\d+:/, 'some fml response' );

# world time
$response = bot_addressed( { from => 'fred', question => 'time in london' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some london time' );

$response = bot_addressed(
    { from => 'fred', question => 'what is the time in brisbane?' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some brisbane time' );

$response = bot_addressed( { from => 'fred', question => 'sydney time?' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some sydney time' );

# banter
$response = bot_addressed( { from => 'fred', question => 'get fucked' } );
ok( $response->[0] =~ /same to you/i, 'responds to swearing' );

foreach my $greet ( 'hello', 'hello there', 'hi', 'hi there', 'good morning' )
{
    $response = bot_addressed( { from => 'fred', question => $greet } );
    ok( $response->[0] =~ /hello/, 'he says hello' );
}

