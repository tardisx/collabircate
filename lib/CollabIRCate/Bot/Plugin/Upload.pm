package CollabIRCate::Bot::Plugin::Upload;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

use CollabIRCate::DB::Token;

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

  unless ( $question =~ /^upload/i ) {
    return;
  }

  my $token = CollabIRCate::DB::Token->new_upload_token($who->db_irc_user()->irc_user(),
                                                        $channel);
  $token->save();

  my $response = CollabIRCate::Bot::Response->new;
  my $link_url = CollabIRCate::Config->http_root() . "/token/upload/" . $token->token;
  $response->add_private_response({user => $who, text => "To upload please click: $link_url"});
  return $response;
}

1;
