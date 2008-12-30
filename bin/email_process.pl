#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use Path::Class;
use lib dir( $Bin, '..', 'lib' )->stringify;

use Carp;
use Pod::Usage;
use Getopt::Long;
use MIME::Parser;
use File::Temp qw/tempfile/;
use File::Spec::Functions qw/catfile/;

use CollabIRCate::Config;
use CollabIRCate::File qw/accept_file/;

my $config = CollabIRCate::Config->config();
my $schema = CollabIRCate::Config->schema();

my ( $debug, $help );

my $options_okay = GetOptions(
  'debug' => \$debug,
  'help'  => \$help,
);

if ($help) {
  pod2usage( -exitval => 1 );
  exit;    # unnecessary
}

### Create a new parser object:
my $parser = new MIME::Parser;

### Tell it where to put things:
$parser->output_under("/tmp");

my @files = glob catfile( $config->{email_queue_path}, "*.mail" );

foreach my $email_filename (@files) {
  warn "working on $email_filename";
  my $entity = $parser->parse_open($email_filename);
#  use Data::Dumper;
#  die Dumper ($entity);
  my $to = $entity->head->get('To');
  if (! defined $to) {
    carp "no To: field in $email_filename";
    next;
  }
  my ($hash) = $to =~ /\b([0-9a-f]{32,})\+/;

  unless ($hash) {
    carp "no hash in To: field on $email_filename";
    next;
  }

  foreach my $this_entity ( $entity->parts ) {
    if ( $this_entity->effective_type ne 'text/plain' ) {
      my $head     = $this_entity->head;
      my $body     = $this_entity->bodyhandle;
      my $filename = $head->recommended_filename;
      my @ids;
      eval { @ids = accept_file( $body->path, $hash ); };
      die $@ if $@;
      if (@ids) {
        if ($debug) {
          warn "Accepted $filename into system, id $_\n" foreach @ids;
        }
      }
      else {
        carp "oh I dunno!";
        next;
      }
    }
  }
  rename $email_filename, $email_filename . ".processed";
}

exit;

__END__

=head1 NAME

email_receive.pl - Receive incoming files from email

=head1 SYNOPSIS



=head1 VERSION

This documentation refers to version 0.0.1

=head1 USAGE



=head1 REQUIRED ARGUMENTS

  
