#!/usr/bin/perl

use File::Temp qw/tempfile/;
my $username = $ENV{SMOLDER_USERNAME};
my $password = $ENV{SMOLDER_PASSWORD};
my $server   = $ENV{SMOLDER_SERVER};
my $port     = $ENV{SMOLDER_PORT};

die unless ($username && $password && $server && $port);

my ($fh, $filename) = tempfile(  TEMPLATE => 'tempXXXXX',
                                 SUFFIX => '.tar.gz');
warn $filename;
my $revision = `git show master^ | grep commit | perl -pne 's/\n//s;'`;
$revision =~ s/^commit\s+//;

my $platform = `uname`;
chomp $platform;

system ("perl", "Makefile.PL");
system ("/usr/bin/prove","--archive",$filename);
system ("/usr/local/bin/smolder_smoke_signal","--server",$server,"--port",$port,"--username",$username,"--password",$password,"--file", $filename,  "--project","collabircate", "--revision", $revision, "--platform", $platform);

unlink $filename;

