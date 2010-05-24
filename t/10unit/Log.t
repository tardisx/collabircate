use strict;
use warnings;
# use Test::More tests => 12;
use Test::More skip_all => 'need to remove old dbix::class stuff';

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

# test for bad tags
{ 
  my $log_id = add_log ( 'person', '#people', 'log', '[o e] [tw ] [ hree]' );
  my $tags = $schema->resultset('Tag');
  my $search_tags = $tags->search( { log_id => $log_id } );
  ok ($search_tags->count == 0, '0 bad tags');
}

# temporarily try a different tag type
{ 
  local CollabIRCate::Config->config->{irc_log_tag_regexp} = '#([\w\S]+)';
  my $log_id = add_log ( 'person', '#people', 'log', '#four #five #six lets go' );
  my $tags = $schema->resultset('Tag');
  my $search_tags = $tags->search( { log_id => $log_id } );
  ok ($search_tags->count == 3, '3 hash tags');
}

# test for multiple tags
{ 
  my $log_id = add_log ( 'person', '#people', 'log', '[one] [two] [three]' );
  my $tags = $schema->resultset('Tag');
  my $search_tags = $tags->search( { log_id => $log_id } );
  ok ($search_tags->count == 3, '3 tags in one line');
}

# test for dodgy tags
{ 
  my $log_id = add_log ( 'person', '#people', 'log', '[one[two]]' );
  my $tags = $schema->resultset('Tag');
  my $search_tags = $tags->search( { log_id => $log_id } );
  ok ($search_tags->count == 1, '1 tag in a nest' );
}
