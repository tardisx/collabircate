use strict;
use warnings;
use Test::More tests => 15;

BEGIN { use_ok 'CollabIRCate::Bot' }

use CollabIRCate::Bot qw/bot_request/;

# general
my $response = bot_request( { from => 'fred', question => 'hello' } );
ok( defined $response->[0], 'can do a request' );

# do some math
$response = bot_request( { from => 'fred', question => 'what is 2+2?' } );
ok( $response->[0] =~ /4/, 'adds 2+2' );

$response = bot_request( { from => 'fred', question => 'what is 1/0' } );
ok( $response->[0] =~ /nice try/i, 'refuses to divide by zero' );

$response = bot_request( { from => 'fred', question => 'no math here!' } );
ok( length $response->[0] > 5, 'responds to no math' ); # he'll say something!

# fml
$response = bot_request( { from => 'fred', question => 'fml' } );
ok( $response->[0] =~ /^\d+:/, 'some fml response' );

# world time
$response = bot_request( { from => 'fred', question => 'time in london' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some london time' );

$response = bot_request(
    { from => 'fred', question => 'what is the time in brisbane?' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some brisbane time' );

$response = bot_request( { from => 'fred', question => 'sydney time?' } );
ok( $response->[0] =~ /\d\d:\d\d:\d\d/, 'got some sydney time' );

# banter
$response = bot_request( { from => 'fred', question => 'get fucked' } );
ok( $response->[0] =~ /same to you/i, 'responds to swearing' );

foreach my $greet ( 'hello', 'hello there', 'hi', 'hi there', 'good morning' )
{
    $response = bot_request( { from => 'fred', question => $greet } );
    ok( $response->[0] =~ /hello/, 'he says hello' );
}

