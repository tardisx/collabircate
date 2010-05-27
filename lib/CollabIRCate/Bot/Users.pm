package CollabIRCate::Bot::Users;

use strict;
use warnings;

use Moose;

use Carp qw/croak/;

use CollabIRCate::DB::User;
use CollabIRCate::DB::IRCUser;
use CollabIRCate::DB::User::Manager;
use CollabIRCate::DB::IRCUser::Manager;

use List::MoreUtils qw/uniq/;

=head1 NAME

CollabIRCate::Bot::Users

=head1 SYNOPSIS

  # get/create a user from his IRC details
  my $user = CollabIRCate::Bot::Users->from_ircuser($nick, $user, $host);

  # return his nickname
  my $nick = $user->get_nick();

  # get a token to provide the user so we can authenticate them
  my $token = $user->get_token();
  # (give them $token)

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
has 'channels' => ( is => 'rw', isa => 'ArrayRef' );

# User object
has 'db_user'     => ( is => 'rw', isa => 'CollabIRCate::DB::User' );
has 'db_irc_user' => ( is => 'rw', isa => 'CollabIRCate::DB::IRCUser' );

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
    my $class    = shift;
    my $nick     = shift;
    my $username = shift;
    my $hostname = shift;

    # do we already know this user?
    my $users = CollabIRCate::DB::IRCUser::Manager->get_ircusers(
        query => [
            irc_user => "$username!$hostname",
            ts       => { gt => time() - 600 },
        ]
    );

    my $irc_user;
    if (@$users) {
        croak "more than one user found?" if ( @$users > 1 );
        $irc_user = $users->[0];

        # update their timestamp
        $irc_user->ts( time() );
        $irc_user->save;
    }
    else {
        $irc_user = CollabIRCate::DB::IRCUser->new(
            irc_user => "$username!$hostname",
            ts       => time()
        )->save;
    }

    my $user = __PACKAGE__->new();
    $user->db_irc_user($irc_user);

    return $user;
}

=head2 link

Link this IRC user to a real user, by username.

=cut

sub link {
    my $self     = shift;
    my $username = shift;

    croak "already linked!" if ( $self->db_user );
    croak "no ircuser!"     if ( !$self->db_irc_user );

    my $users = CollabIRCate::DB::User::Manager->get_users(
        query => [ username => $username ] );

    if ( !@$users ) {
        croak "no user found";
    }
    elsif ( !@$users > 1 ) {
        croak "too many users found";
    }
    my $user = $users->[0];
    $self->db_user($user);
    $self->db_irc_user->user_id($user->id);
    $self->db_irc_user->ts(time);
    $self->db_irc_user->save;
    return 1;
}

=head2 add_channel

Adds one channel to the list of channels that this user is on.

=cut

sub add_channel {
    my $self     = shift;
    my $channel  = shift;
    my @channels = @{ $self->channels };
    push @channels, $channel;
    @channels = uniq(@channels);
    $self->channels( \@channels );
}

=head2 remove_channel

Removes a channel from the list of channels that this user is on.

=cut

sub remove_channel {
    my $self     = shift;
    my $channel  = shift;
    my @channels = grep { !/^$channel$/ } @{ $self->channels };
    $self->channels( [@channels] );
}

=head2 update_logs

Updates the logs for a user, once that user has become identified.

=cut

sub update_logs {
    my $self = shift;
    croak "not an identified user!" unless $self->is_identified;
    croak "unimplemented";
}

=head2 id

Return the id for this user

=cut

sub id {
    my $self = shift;
    return 1;    # XXX

}

1;
