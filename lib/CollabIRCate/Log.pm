package CollabIRCate::Log;

use strict;
use warnings;
use Carp qw/croak confess/;

use CollabIRCate::Config;

use CollabIRCate::DB::Channel;
use CollabIRCate::DB::Log;

use CollabIRCate::Bot::Users;

use DateTime;

use Exporter qw/import/;
our @EXPORT_OK = qw/add_log/;

our $config = CollabIRCate::Config->config();

sub add_log {
    my ( $who, $where, $type, $what ) = @_;
    $where = lc($where);

=pod

    confess "not a CollabIRCate::Bot::Users"
        unless $who->isa('CollabIRCate::Bot::Users');

    # If this user if known to us, use them, otherwise use their nick.
    my ( $user_id, $irc_user );
    if ( $who->is_identified ) {
        $user_id = $who->user;
    }
    else {
        $irc_user = $who->irc_user;
    }

=cut
    my $irc_user = $who;
    my $user_id = undef;

    my $channel = CollabIRCate::DB::Channel->new( name => $where );
    $channel->insert_or_update();
    
    my $log = CollabIRCate::DB::Log->new(
          channel_id => $channel->id,
          user_id    => $user_id,
          entry      => $what,
          type       => $type,
          ts         => DateTime->now(),
      )->save;


#    _add_tags( $what, $log->id );

    return $log->id;

}

=pod

sub _add_tags {
    my $msg    = shift;
    my $log_id = shift;

    croak "no irc_log_tag_regexp in config"
        unless $config->{irc_log_tag_regexp};
    my $regex = qr/$config->{irc_log_tag_regexp}/;

    while ( $msg =~ s/$regex// ) {
        my $tag = $schema->resultset('Tag')->find_or_create(
            {   log_id => $log_id,
                name   => $1
            }
        );
    }
    return;
}

=cut

1;
