package CollabIRCate::Bot::Users;

use strict;
use warnings;

use Moose;

use Carp qw/croak/;

use CollabIRCate::Logger;
use CollabIRCate::DB::User;
use CollabIRCate::DB::IRCUser;
use CollabIRCate::DB::Nick;
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

  # link this IRC user to a real user
  $user->link($real_username);

=head1 DESCRIPTION

This module provides an abstraction for dealing with IRC user instances - a
particular user logged in at a particular time, who may be identified as as
real authenticated user at some point.

Instead of trying to enforce the identity of the user at some IRC level, we
put the onus on the user themselves. Using methods here, the bot can determine
if we know the use or not based on their IRC nick name and some sort of state,
and provide a token back to the user to prove their identity (via the web or
some other means).

During the lifetime of the IRC server, users will come and go. Each user that
the bot needs to deal with will be one of these objects. It may be linked to
a real user, if we have some somehow authenticated them.

=head1 CAUTIONS

Since some of the information about the user lives in the database (for access
by outside processes, and to maintain persistence) we need to take care when
data may be used by 'the outside world'. For instance an email may arrive which
links an IRC user instance to a real user, invalidating some of the data on the
object stored here. Where appropriate, objects should refresh data from the
database before use.

=cut

# IRC components
# their current nick
has 'nick'      => ( is => 'rw', isa => 'Str' );

# where we can see them
has 'channels' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

# User object
has 'db_irc_user' => ( is => 'rw', isa => 'CollabIRCate::DB::IRCUser' );

# timeout - how long we believe a user to be the same, if username and hostname
# match
my $timeout = 600; # XXX needs to be configurable

my $logger = CollabIRCate::Logger->get(__PACKAGE__);

# who we know about
my @known_users = ();

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

    $logger->debug("from_ircuser for '$username!$hostname' ('$nick')");

    # do we already know about this user?
    foreach my $a_user (@known_users) {
        if ($a_user->db_irc_user()->irc_user() eq "$username!$hostname") {
            $logger->debug("'$username!$hostname' is known to us, updating");
            $a_user->db_irc_user()->load;
            $a_user->db_irc_user()->ts(time());
            $a_user->db_irc_user()->save();
            $a_user->update_nick($nick);
            $a_user->db_irc_user()->save();
 
            return $a_user;
        }
    }

    # do we already know this user (in the db but not in memory)?
    my $users = CollabIRCate::DB::IRCUser::Manager->get_ircusers(
        query => [
            irc_user => "$username!$hostname",
            ts       => { gt => time() - $timeout },
        ]
    );

    my $irc_user;
    if (@$users) {
        $logger->debug("found in db");
        croak "more than one user found?" if ( @$users > 1 );
        $irc_user = $users->[0];

        # update their timestamp and nick
        $logger->debug("updating db timestamp and saving");
        $irc_user->ts( time() );
        $irc_user->save;
    }
    else {
        $logger->debug("not in db - create a new record");
        $irc_user = CollabIRCate::DB::IRCUser->new(
            irc_user => "$username!$hostname",
            ts       => time(),
            nick     => { nick => $nick, ts => time() },
        )->save;
    }

    $logger->debug("creating a new object");
    my $user = __PACKAGE__->new();
    $user->db_irc_user($irc_user);

    $logger->debug("setting the nick to '$nick'");
    $user->update_nick($nick);

    push @known_users, $user;
    
    return $user;
}

=head2 link

Link this IRC user to a real user, by username.

=cut

sub link {
    my $self     = shift;
    my $username = shift;

    croak "no ircuser!" if ( !$self->db_irc_user );
    croak "already linked!" if ( $self->db_irc_user->user_id );

    my $users = CollabIRCate::DB::User::Manager->get_users(
        query => [ username => $username ] );

    if ( !@$users ) {
        croak "no user found";
    }
    elsif ( !@$users > 1 ) {
        croak "too many users found";
    }
    my $user = $users->[0];
    $self->db_irc_user->user_id( $user->id );
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

Return the id for this irc user

=cut

sub id {
    my $self = shift;
    croak "No db_irc_user" unless $self->db_irc_user;

    return $self->db_irc_user->id;
}

sub from_nick {
    my $class = shift;
    return __PACKAGE__->from_ircuser( shift, 'na', 'na' );
}

=head2 update_nick

Update the nick in the database if necessary.

=cut

sub update_nick {
  my $self = shift;
  my $nick = shift;

  # XXX fix this - it needs to only add a row if there is not one
  # for this nick already
  my $newnick = CollabIRCate::DB::Nick->new(irc_user_id=>$self->db_irc_user()->id(),
                                            ts => time(),
                                            nick=>$nick)->save;
}
  

1;
