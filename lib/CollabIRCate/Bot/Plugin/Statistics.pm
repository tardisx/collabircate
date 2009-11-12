package CollabIRCate::Bot::Plugin::Statistics;

use strict;
use warnings;

use CollabIRCate::Bot::Response;

use Carp qw/croak/;

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
    my ($who, $where, $message) = @_;
    warn "$who said $message at $where";
}

# when addressed, if it's about stats hook them up with some numbers
sub stats {
    my ($who, $where, $message) = @_;
    return unless $message =~ /stats/i;

    my $response = CollabIRCate::Bot::Response->new();
    $response->public_response(['thats nice']);
    return $response;

}

# record who is online for statistics purposes
sub periodic {
    my @stuff = @_;
    croak __PACKAGE__ . " periodic";
}

1;
