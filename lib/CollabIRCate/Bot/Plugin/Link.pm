package CollabIRCate::Bot::Plugin::Link;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

=head2 register

Registers the link plugin.

=cut

sub register {
    return { addressed => \&answer };
}

=head2 answer

Answer a request.

=cut

sub answer {
  my ($who, $channel, $question) = @_;

  unless ( $question =~ /^link/i ) {
    return;
  }

  my $result = "hello link requester!! ";

  my $response = CollabIRCate::Bot::Response->new;
  $response->add_private_response({user => $who, text => $result});
  return $response;
}

1;
