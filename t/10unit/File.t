use strict;
use warnings;
use Test::More tests => 12;

BEGIN {
    $ENV{'COLLABIRCATE_CONFIG_SUFFIX'} = '.sample';
}

use File::Temp qw/tempfile/;
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
}

# text file
{
    my ($fh, $filename) = tempfile();
    print $fh "this is just plain text\n";
    print $fh "quite boring really!\n";
    print $fh "EOF\n";
    close $fh;
    my $db = CollabIRCate::DB::File->new_from_file($filename,
                                                   $channel->id,
                                                   $user->id);

    ok ($db->id, 'has an id');
    ok ($db->size == 49, 'has the right size');
    ok ($db->mime_type eq 'text/plain', 'right mime type');
}


# gif file
{
    my $db = CollabIRCate::DB::File->new_from_file('testdata/testgif.gif',
                                                   $channel->id,
                                                   $user->id);

    ok ($db->id, 'has an id');
    ok ($db->size == 800, 'has the right size');
    ok ($db->mime_type eq 'image/gif', 'right mime type');
}

# jpg file
{
    my $db = CollabIRCate::DB::File->new_from_file('testdata/testjpg.jpg',
                                                   $channel->id,
                                                   $user->id);

    ok ($db->id, 'has an id');
    ok ($db->size == 3222, 'has the right size');
    ok ($db->mime_type eq 'image/jpeg', 'right mime type');
}

