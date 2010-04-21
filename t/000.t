use Test::More tests => 1;

unlink 'collabircate_dev.db';
system ('sqlite3 collabircate_dev.db < etc/schema_sqlite.sql');

ok (-s 'collabircate_dev.db' > 2, 'db looks ok');
