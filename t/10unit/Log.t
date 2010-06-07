use strict;
use warnings;
use Test::More tests => 5;

BEGIN { use_ok 'CollabIRCate::Log' }

use CollabIRCate::DB::Log::Manager;
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
