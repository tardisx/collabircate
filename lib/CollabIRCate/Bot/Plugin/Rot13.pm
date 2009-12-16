package CollabIRCate::Bot::Plugin::Rot13;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub register {
    return { public => \&answer };
}

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
