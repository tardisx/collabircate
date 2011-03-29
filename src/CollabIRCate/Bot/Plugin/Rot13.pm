package CollabIRCate::Bot::Plugin::Rot13;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

=head2 register

Registers the Rot13 plugin. The Rot13 plugin answers requests to rot13
strings.

=cut

sub register {
    return { public => \&answer };
}

=head2 answer

Answer a request.

=cut

sub answer {
  my ($who, $channel, $question) = @_;

  unless ( $question =~ /^rot13\s*(.*)/i ) {
    return;
  }

  my $result = $1;
  $result =~ y/A-Za-z/N-ZA-Mn-za-m/;

  my $response = CollabIRCate::Bot::Response->new;
  $response->add_public_response({channel => $channel, text => $result});
  return $response;
}

1;
