package CollabIRCate::Log;

use strict;
use warnings;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;
use CollabIRCate::Schema::Tag;

use Exporter qw/import/;
our @EXPORT_OK = qw/add_log/;

our $schema;

sub _schema {

    return $schema if ( defined $schema );

    $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
        || die $!;

    return $schema;

}

sub add_log {
    my ( $who, $where, $type, $what ) = @_;
    $where = lc($where);

    my $user
        = _schema->resultset('Users')->find_or_create( { email => $who } );
    my $channel
        = _schema->resultset('Channel')->find_or_create( { name => $where } );
    my $log = _schema->resultset('Log')->create(
        {   channel_id => $channel,
            users_id   => $user,
            entry      => $what,
            type       => $type,
        }
    );

    _add_tags( $what, $log->id );

    return $log->id;

}

sub _add_tags {
    my $msg    = shift;
    my $log_id = shift;

    while ( $msg =~ /\[\w+\]/ ) {
        $msg =~ s/\[(\w+)\]//g;
        my $tag = _schema->resultset('Tag')->find_or_create(
            {   log_id => $log_id,
                name   => $1
            }
        );
    }
    return;
}

1;
