package CollabIRCate::Bot::Users;

use strict;
use warnings;

use Moose;

=head1 NAME

CollabIRCate::Bot::Users

=head1 SYNOPSIS

  my $user = CollabIRCate::Bot::Users->new_from_ircnick($ircnick);

  # get a token to provide the user so we can authenticate them
  my $token = $user->get_token();

  # [time passes]
  # do we know them now?
  if ($user->is_identified) {
    # update the logs now that we know who they are
    $user->update_logs();
  }

=head1 DESCRIPTION

Methods to allow the CollabIRCate Bot to deal with users, including the
uncertainity of their identification.

Instead of trying to enforce the identity of the user at some IRC level, we
put the onus on the user themselves. Using methods here, the bot can determine
if we know the use or not based on their IRC nick name and some sort of state,
and provide a token back to the user to prove their identity (via the web or
some other means).

=cut

has 'irc_nick' => ( is => 'rw', isa => 'Str' );
has 'user'     => ( is => 'rw', isa => 'CollabIRCate::Schema::Users' );

sub is_identified {
    my $self = shift;
    return 1 if ( $self->user );
    return 0;
}

sub update_logs {
    my $self = shift;
    croak "not an identified user!" unless $self->user;
    croak "unimplemented";
}

1;
