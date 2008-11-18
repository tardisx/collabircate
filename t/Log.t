use strict;
use warnings;
use Test::More tests => 9;

BEGIN { use_ok 'CollabIRCate::Log' }

use CollabIRCate::Log qw/add_log/;
use CollabIRCate::Config;

my $unique = $$ . time();

eval { add_log( 'person', '#people', 'log', 'friendly ' . $unique ); };

ok( !$@, 'add_log' );

my $log_id;
eval { $log_id = add_log( 'person', '#people', 'log', "[$unique]" ); };

ok( !$@, 'add_log with tag' );

ok( defined $log_id && $log_id > 0, 'log_id exists and is positive' );

my $schema = CollabIRCate::Config->schema;

ok( defined $schema, 'got schema object' );

my $tags = $schema->resultset('Tag');
ok( defined $tags, 'got some tags' );
my $search_tags = $tags->search( { name => $unique } );

my $our_tag = $search_tags->next;
ok( defined $our_tag && $our_tag->name eq $unique, 'got our tag' );
my $next_tag = $search_tags->next;
ok( !defined $next_tag, 'it was the only one' );

# test for multiple tags
{ 
  my $log_id = add_log ( 'person', '#people', 'log', '[one] [two] [three]' );
  my $tags = $schema->resultset('Tag');
  my $search_tags = $tags->search( { log_id => $log_id } );
  my $count = 0;
  while ($search_tags->next) {
    $count++;
  }
  ok ($count == 3, '3 tags in one line');
}


