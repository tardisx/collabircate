#!/usr/bin/perl

use File::Temp qw/tempfile/;
use LWP::UserAgent;
use HTTP::Cookies;

my $username  = $ENV{SMOLDER_USERNAME};
my $password  = $ENV{SMOLDER_PASSWORD};
my $server    = $ENV{SMOLDER_SERVER};
my $port      = $ENV{SMOLDER_PORT};
my $projectid = $ENV{SMOLDER_PROJECTID};

die unless ($username && $password && $server && $port && $projectid);

my ($fh, $filename) = tempfile(  TEMPLATE => 'tempXXXXX',
                                 SUFFIX => '.tar.gz');
my $revision = `git show master^ | grep commit | perl -pne 's/\n//s;'`;
$revision =~ s/^commit\s+//;

my $platform = `uname`;
chomp $platform;

system ("/usr/bin/prove","-Ilib", "-r","--archive",$filename);

my $agent = LWP::UserAgent->new(cookie_jar=> {});
my $response;
$response  = $agent->post(
  "http://$server:$port/app/public_auth/process_login",
  Content => [ username => $username, password => $password ]);
die "bad login" unless $response->code == 302;

$response = $agent->post(
  "http://$server:$port/app/projects/process_add_report/$projectid",
  Content_Type => 'multipart/form-data',
  Content      => [
    platform     => $platform,
    revision => $revision,
    report_file  => [ $filename ],
  ]
);
die "bad submission" unless $response->code == 302;

unlink $filename;

