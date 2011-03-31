use strict;
use warnings;
use Test::More tests => 13;

BEGIN { use_ok 'CollabIRCate::Log' }

use CollabIRCate::DB::Log::Manager;
use CollabIRCate::DB::User;
use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Config;

my $unique = $$ . time();
my $bot_user = CollabIRCate::Bot::Users->bot_ircuser();
my $user     = CollabIRCate::Bot::Users->from_ircuser('fred', 'freddy', 'localhost');

eval { add_log( $user, '#people', 'log', 'friendly ' . $unique ); };

ok( !$@, 'add_log' );

my $log_id;
$log_id = add_log( $user, '#people', 'log', "$unique something");
ok( defined $log_id && $log_id > 0, 'log_id exists and is positive' );

my $new_log_id;
$new_log_id = add_log( $user, '#people', 'log', "$unique something");
ok( $log_id < $new_log_id, 'logs are incrementing');

my $logs = CollabIRCate::DB::Log::Manager->get_logs(
    query => [ entry => { like => "%" . $unique . " something%" } ]
);

ok (@$logs == 2, 'two logs created');

my $a_new_user = CollabIRCate::Bot::Users->from_ircuser('johnny', 'johnnysbox', 'some.host');
add_log( $a_new_user, '#somechan', 'log', 'say something '.$unique );

my $dbuser = CollabIRCate::DB::User->new(email => 'j@j.com', username => 'johnno', password => 'fude')->save();
ok (defined $dbuser, 'made johnny user');
ok ($dbuser->id() =~ /\d+/, 'has an id');
ok ($a_new_user->link('johnno'), 'linked him');

$logs = CollabIRCate::DB::Log::Manager->get_logs(
    query => [ entry => 'say something '.$unique ], 
);

ok (@$logs == 1, 'one johnny log');
my $j_log = $logs->[0];
ok (defined $j_log->irc_user, 'can get to irc_user');
ok (defined $j_log->irc_user->user, 'can get to real user');
ok ($j_log->irc_user->user->id() =~ /\d+/, 'has an id');
ok ($j_log->irc_user->user->id() == $dbuser->id(), 'heeeeeeeeeres johnny');
