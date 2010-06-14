use strict;
use warnings;
use Test::More tests => 3;

BEGIN {
    $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} = '.sample';
}

# use File::Temp qw/tempfile/;
#use CollabIRCate::Config;
use CollabIRCate::DB::File;
use CollabIRCate::DB::Channel;
use CollabIRCate::DB::User;
use DateTime;

# create some fake people and places.
my $channel
    = CollabIRCate::DB::Channel->new( name => '#filetest' . $$ )->save();
my $user = CollabIRCate::DB::IRCUser->new(
    irc_user => 'justin!localhost',
    ts       => DateTime->now()
)->save();

# test storing some files
{

    my $file = CollabIRCate::DB::File->new(
        ts          => DateTime->now(),
        filename    => 'foobar.txt',
        irc_user_id => $user->id,
        channel_id  => $channel->id,
        mime_type   => 'text/plain',
        size        => 100

    )->save;
    ok( $file,       "got a file" );
    ok( $file->id,   "has an id" );
    ok( $file->path, "has a path" );

    warn $file->path;

}

