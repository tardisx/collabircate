use Test::More tests => 6;

use_ok 'CollabIRCate::Bot::Response';

my $response = CollabIRCate::Bot::Response->new();
ok ($response, 'response object');

ok ($response->add_public_response({channel => '#foo', text => 'hello!'}), 'add public response');
ok (@{$response->public_response} == 1, 'one public response');

eval {
    $response->add_private_response({text => 'hello!'});
};
ok ($@ =~ /no user for private/, 'no user');

eval {
    $response->add_private_response({text => 'hello!', user => 'fred'});
};
ok ($@ =~ /not a CollabIRCate::Bot::Users/, 'bad user');

1;
