package CollabIRCate::Bot::Users;

use strict;
use warnings;

use Moose;

use Carp qw/croak/;

use List::MoreUtils qw/uniq/;

=head1 NAME

CollabIRCate::Bot::Users

=head1 SYNOPSIS

  # get/create a user from his IRC details
  my $user = CollabIRCate::Bot::Users->from_ircuser($nick, $user, $host);

  # return his nickname
  my $nick = $user->get_nick();

  # 

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

During the lifetime of the IRC server, users will come and go. Each user that
the bot needs to deal with will be one of these objects. It may be linked to
a real user, if we have some somehow authenticated them.

=cut

# IRC components
has 'nick'      => ( is => 'rw', isa => 'Str' );
has 'username'  => ( is => 'rw', isa => 'Str' );
has 'hostname'  => ( is => 'rw', isa => 'Str' );
has 'last_seen' => ( is => 'rw', isa => 'Int' );

# where we can see them
has 'channels'  => ( is => 'rw', isa => 'ArrayRef');
                     
# User object
has 'user' => ( is => 'rw', isa => 'CollabIRCate::Schema::Users' );

# Users we currently know about
our @known_users = ();

=head2 from_ircuser

Return a L<CollabIRCate::Bot::Users> object given the 3 parameters:

=over 4

=item * nickname

=item * username

=item * hostname

=back

This has the side-effect of updating the existing known user's nick and
last_seen timestamp, if they were already known to us.

This will return the existing user, if they were already known to us, or
create a new one if not.

=cut

sub from_ircuser {
    my $class = shift;
    my $nick  = shift;
    my $username = shift;
    my $hostname = shift;

    # do we already know this user?
    foreach my $check_user (@known_users) {
        if (   $username eq $check_user->username()
            && $hostname eq $check_user->hostname() )
        {

         # update the nick, they might have changed while we weren't watching!
            $check_user->nick($nick);
            $check_user->last_seen( time() );
            return $check_user;
        }
    }

    # no, lets create a new one
    my $user = __PACKAGE__->new(
        {   nick      => $nick,
            username  => $username,
            hostname  => $hostname,
            last_seen => time(),
            channels  => [],
        }
    );

    push @known_users, $user;

    return $user;
}

=head2 from_nick

Find the user from a nickname. We never create this user, we must already have
knowledge of them.

=cut

sub from_nick {
    my $class = shift;
    my $nick  = shift;

    foreach my $check_user (@known_users) {
        if ($check_user->nick eq $nick) {
            return $check_user;
        }
    }
    return;
}

=head2 add_channel

Adds one channel to the list of channels that this user is on.

=cut

sub add_channel {
    my $self = shift;
    my $channel = shift;
    my @channels = @{ $self->channels };
    push @channels, $channel;
    @channels = uniq(@channels);
    $self->channels( \@channels );
}

=head2 remove_channel

Removes a channel from the list of channels that this user is on.

=cut

sub remove_channel {
    my $self = shift;
    my $channel = shift;
    my @channels = grep { !/^$channel$/} @{ $self->channels };
    $self->channels( [ @channels ] );
}

=head2 is_identified

Checks if a user has been identified to us.

=cut

sub is_identified {
    my $self = shift;
    return 1 if ( $self->user );
    return 0;
}

=head2 update_logs

Updates the logs for a user, once that user has become identified.

=cut

sub update_logs {
    my $self = shift;
    croak "not an identified user!" unless $self->is_identified;
    croak "unimplemented";
}

=head2 list_users

List all users known to the Bot.

=cut

sub list_users {
    my $class = shift;
    return @known_users;
}

=head2 one_channel

Sometimes it is important to know that the user is on one channel and
only one channel. Some instructions are received via a private message
that will affect a channel (file upload for example). In the simple case,
if the user is only on one channel, then we can go straight ahead without
any confirmation about what channel the user meant.

=cut

sub one_channel {
    my $self = shift;
    my @channels = @{ $self->channels };
    if (scalar @channels == 1) {
        return $channels[0];
    }
    else {
        return;
    }
}

sub dump {
    use Data::Dumper;
    print Dumper \@known_users;
}
      
       

1;
