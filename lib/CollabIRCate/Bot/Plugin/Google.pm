package CollabIRCate::Bot::Plugin::Google;

use strict;
use warnings;

use REST::Google;

use base 'CollabIRCate::Bot::Plugin';

sub answer {
  my $class = shift;
  my $question = shift;
  return undef unless ( $question =~ /google\s+(.*)/i );

  my $q = $1;
  $q =~ s/[^\w\s]//g;

  # set service to use
  REST::Google->service(
    'http://ajax.googleapis.com/ajax/services/search/web');

  # provide a valid http referer
  REST::Google->http_referer('http://collabircate.eatmorecode.com');

  my $res = REST::Google->new( q => $q );

  return [ 'google response failure', undef ]
    if $res->responseStatus != 200;

  my $data = $res->responseData;

  my $result =
    $data->{results}->[0]->{url} . ' | '
      . $data->{results}->[0]->{content};

  $result =~ s{</?b>}{}g;

  return { answer => $result };

}

1;
