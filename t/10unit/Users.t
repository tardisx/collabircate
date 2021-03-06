use Test::More tests => 15;

BEGIN {
use_ok 'CollabIRCate::Bot::Users';
}

# fake user
my $user = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# make sure a DB record was created
ok ($user->db_irc_user, 'db user created');
ok ($user->db_irc_user->id, 'has an id');
ok ($user->db_irc_user->ts->epoch > (time() - 10), 'has a timestamp that is valid');
my $ts = $user->db_irc_user->ts->epoch; # remember the ts
sleep 2; # so it is out of date

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

# grab user 1 again
my $user_again = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddofrog', 'localhost');

# its timestamp should be bigger than before
my $now = $user_again->db_irc_user->ts->epoch;
ok ($now > $ts, 'timestamp updated');

# in fact, they are the same user now
ok ($user_again eq $user, 'identical user');

# let's change his nick though and make sure he's still the same guy
my $user_again_new_nick = CollabIRCate::Bot::Users->from_ircuser('brandnewfred', 'freddofrog', 'localhost');
ok ($user_again_new_nick eq $user, 'identical user');

# test we can navigate from the bot user, to the irc_user (db) through to the real user.
ok (defined $user->db_irc_user, 'there is a db_irc_user');
ok ($user->db_irc_user->id() =~ /\d+/, 'has an id');
ok (defined $user->db_irc_user->user(), 'can get to user');
ok (defined $user->db_irc_user->user()->id() =~ /\d+/, 'has a user id');

