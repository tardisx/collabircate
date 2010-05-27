use Test::More tests => 4;

BEGIN {
    use_ok 'CollabIRCate::Bot::Users';
}

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# link it to the real (test) user
ok ($user->link('foo'), 'can link');
eval { $user->link('foo') };
ok ($@ =~ /already linked/ , 'can\'t link again');

# can't link to someone else
eval { $user->link('bar') };
ok ($@ =~ /already linked/, 'can\'t link to someone else');




