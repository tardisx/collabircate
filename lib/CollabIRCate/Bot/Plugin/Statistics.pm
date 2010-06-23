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
use Storable qw/store retrieve/;

use base 'CollabIRCate::Bot::Plugin';

our $data;

BEGIN {
  eval { $data = retrieve('stats.sb'); };
  if ($@) {
    $data = {};
  }
}

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
    my ($who, $channel, $message) = @_;
    my $day = sprintf("%04d-%02d-%02d", (localtime())[5]+1900,
                                        (localtime())[4]+1,
                                        (localtime())[3]);
    my $hour = sprintf("%02d", (localtime())[2]);

    $data->{$channel}->{by_hour}->{$hour}++;
    $data->{$channel}->{by_date}->{$day}++;

    store($data, 'stats.sb');
    return;
}

=head2 stats

Report statistics to the channel or user.

=cut

sub stats {
    my ($who, $channel, $message) = @_;
    return unless $message =~ /stats/i;
    use Data::Dumper;
    $Data::Dumper::Sortkeys = 1;
   
    my $response = CollabIRCate::Bot::Response->new;
    $response->add_public_response(
        { channel => $channel,
          text    => Dumper($data),
        });
    return $response;
}

1;
