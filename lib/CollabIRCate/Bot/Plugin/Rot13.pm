package CollabIRCate::Bot::Plugin::Rot13;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub answer {
  my ($class, $question) = @_;

  unless ( $question =~ /^rot13:*\s*(.*)/i ) {
    return undef;
  }
  my $result = $1;
  $result =~ y/A-Za-z/N-ZA-Mn-za-m/;

  return { answer => $result };
}

1;
