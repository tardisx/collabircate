use Test::More tests => 1;
BEGIN {
    $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} = '.sample';
    use CollabIRCate::Config;
}

my $config = CollabIRCate::Config->config();

if ($config->{database_type} eq 'sqlite') {
  unlink 'collabircate_dev.db';
  system ('sqlite3 collabircate_dev.db < etc/schema_sqlite.sql');
  system ('sqlite3 collabircate_dev.db < etc/testdata.sql');
  ok (-s 'collabircate_dev.db' > 2, 'db looks ok');
}
elsif ($config->{database_type} eq 'pg') {
  system ('/usr/local/pgsql/bin/psql collabircate_dev < etc/schema_pg.sql');
  ok (! $!, 'pg worked');
  system ('/usr/local/pgsql/bin/psql collabircate_dev < etc/testdata.sql');
}
else {
  fail ('oops');
}
