use Test::More tests => 2;

BEGIN {
    use_ok 'CollabIRCate::Bot::Users';
}

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# link it to the real (test) user
ok ($user->link(1), 'can link');


