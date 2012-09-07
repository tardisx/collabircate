#!/usr/bin/env perl

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

my ($debug, $help);

my $options_okay = GetOptions(
    'debug'     => \$debug,
    'help'      => \$help,
);

if ( $help ) {
    pod2usage( -exitval => 1 );
    exit;    # unnecessary
}

# Mail comes from the MTA on stdin, and we cram it into a data structure
# and send it through to the API on the server (possibly localhost). This
# obviates all need for rubbish like queue dirs and permissions and so on.
#
# It also possibly imposes a hard limit on how much big an incoming mail
# we can process is, but that's probably ok, we'd like to encourage people
# to use more appropriate (read: DCC or HTTP) methods to upload multi-
# megabyte files.
#

exit;

__END__

=head1 NAME

email_receive.pl - Receive incoming files from email

=head1 SYNOPSIS



=head1 VERSION

This documentation refers to version 0.0.1

=head1 USAGE



=head1 REQUIRED ARGUMENTS

  
