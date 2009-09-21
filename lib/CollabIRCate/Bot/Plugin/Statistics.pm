package CollabIRCate::Bot::Plugin::Statistics;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub register {
    return {
        public    => \&record,
        addressed => \&stats,
        periodic  => [ 60, \&periodic ],
    };
}

# any public message, record the statistics
sub record {
    my @stuff = @_;
    die @stuff;
}

# when addressed, if it's about stats hook them up with some numbers
sub stats {
    my ($who, $where, $message) = @_;
    return unless $message =~ /stats/i;
    die $message;
}

# record who is online for statistics purposes
sub periodic {
    my @stuff = @_;
    die @stuff;
}

1;
