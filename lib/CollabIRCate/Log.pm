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

    confess "not a CollabIRCate::Bot::Users"
        unless $who->isa('CollabIRCate::Bot::Users');

    my $channel = CollabIRCate::DB::Channel->new( name => $where );
    $channel->insert_or_update();
    
    my $log = CollabIRCate::DB::Log->new(
          channel_id => $channel->id,
          irc_user   => $who->db_irc_user->id,
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
