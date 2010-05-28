use Test::More tests => 5;

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

# let's say that poor old fred gets disconnected, logs on from another machine and 
# with a new nick. no reason we can't also associate him...
my $user2 = CollabIRCate::Bot::Users->from_ircuser('newfred', 'newusername', 'a.brand.new.host');
ok ($user2->link('foo'), 'can link same user to a new irc_user');


