package CollabIRCate::Logger;

use strict;
use warnings;

use Log::Log4perl;

Log::Log4perl::init_and_watch('etc/log4perl.conf', 10);


sub get {
    return Log::Log4perl->get_logger(shift);
}

1;
