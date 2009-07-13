package CollabIRCate::Bot::Plugin::FML;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

use LWP::Simple;
use XML::Simple;    # lets be simple

my $url = 'http://api.betacie.com/view/random?language=en';

sub answer {
  my ($class, $question) = @_;

  unless ( $question =~ /fml/i ) {
    return;
  }

  my $xml;
  my $xml_ref;

  eval {
    $xml     = get $url;
    $xml_ref = XMLin($xml);
  };

  if ($@) {
    return { answer => "Today, the FML server failed to respond. FML" };
  }

  my $id   = $xml_ref->{items}->{item}->{id};
  my $text = $xml_ref->{items}->{item}->{text};

  my $result =  "$id: $text";

  if ((! $id) || (! $text)) {
    return { answer => "Today, the FML server failed to respond. FML" };
  }

  return { answer => $result };
}

1;
