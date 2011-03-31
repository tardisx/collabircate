package CollabIRCate::Logger;

=head1 NAME

CollabIRCate::Logger - a simple wrapper around Log::Log4perl

=head2 SYNOPSIS

  package CollabIRCate::Some::Class;

  use CollabIRCate::Logger;

  my $logger = CollabIRCate::Logger->get();
  $logger->info("something informative");

=cut

use strict;
use warnings;

use Log::Log4perl;

Log::Log4perl::init_and_watch('etc/log4perl.conf', 10);
  ...

=head2 get

Returns the logger object.

=cut

sub get {
    my $class = shift;
    my $logger = Log::Log4perl->get_logger(shift);
    return $logger;
}

1;
