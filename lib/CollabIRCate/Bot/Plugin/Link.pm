package CollabIRCate::Bot::Plugin::Link;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

use CollabIRCate::DB::Token;
use CollabIRCate::Config;

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

  my $token = CollabIRCate::DB::Token->new_link_token($who->db_irc_user()->irc_user());
  $token->save();

  my $response = CollabIRCate::Bot::Response->new;
  my $link_url = CollabIRCate::Config->http_root() . "/token/link/" . $token->token;
  $response->add_private_response({user => $who, text => $link_url});
  return $response;
}

1;
