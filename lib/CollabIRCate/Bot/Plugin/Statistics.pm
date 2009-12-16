package CollabIRCate::Bot::Plugin::Statistics;

use strict;
use warnings;

=head1 NAME

CollabIRCate::Bot::Plugin::Statistics - collect and report channel statistics

=head1 DESCRIPTION

This plugin causes the bot to record all manner of interesting channel-related
statistics, and to report them to the user when asked.

=head1 METHODS

=cut

use CollabIRCate::Bot::Response;

use Carp qw/croak/;

use base 'CollabIRCate::Bot::Plugin';

sub register {
    return {
        public    => \&record,
        addressed => \&stats,
    };
}

=head2 record

Record details on every single public mesage we see.

=cut

sub record {
    my ($who, $where, $message) = @_;
    warn "$who said $message at $where";
    return undef; # no response
}

=head2 stats

Report statistics to the channel or user.

=cut

sub stats {
    my ($who, $where, $message) = @_;
    return unless $message =~ /stats/i;

    my $response = CollabIRCate::Bot::Response->new();
    $response->public_response(['thats nice']);
    return $response;

}

1;
