#!/usr/bin/perl

use strict;
use warnings;

use Carp qw/croak/;

use FindBin qw/$Bin/;
use Path::Class;
use File::Spec::Functions qw/catfile/;
use lib dir( $Bin, '..', 'lib' )->stringify;
use Getopt::Long;

use CollabIRCate::Config;
use CollabIRCate::File qw/accept_file/;

my $config = CollabIRCate::Config->config();
my $queue_dir = $config->{email_queue_path} || croak "no email_queue_path";

my ($debug, $help);

my $options_okay = GetOptions(
    'debug'     => \$debug,
    'help'      => \$help,
);

if ( $help ) {
    pod2usage( -exitval => 1 );
    exit;    # unnecessary
}

# file comes in from the MTA on stdin, we must just store it into 
# a directory
croak "no such dir $queue_dir" unless (-d $queue_dir);
my $filename = catfile($queue_dir, $$ . "-" . time());
open my $fh, ">", $filename . ".tmp" || croak "oh no";
while (<>) {
  print $fh $_;
}
close $fh || croak "oh no!";
chmod 0644, "$filename.tmp";
rename "$filename.tmp", "$filename.mail" || croak "oh no!";

exit;

__END__

=head1 NAME

email_receive.pl - Receive incoming files from email

=head1 SYNOPSIS



=head1 VERSION

This documentation refers to version 0.0.1

=head1 USAGE



=head1 REQUIRED ARGUMENTS

  
