package CollabIRCate::Logger;

use strict;
use warnings;

use Log::Log4perl;

Log::Log4perl::init_and_watch('etc/log4perl.conf', 10);


sub get {
    my $class = shift;
    my $logger = Log::Log4perl->get_logger(shift);
    return $logger;
}

1;
