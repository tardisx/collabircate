package CollabIRCate::Log;

use strict;
use warnings;

use CollabIRCate::Schema;
use CollabIRCate::Schema::Channel;

use Exporter qw/import/;
our @EXPORT_OK = qw/add_log/;

our $schema;

sub _schema {

    return $schema if (defined $schema);

    $schema = CollabIRCate::Schema->connect('dbi:Pg:dbname=collabircate')
	|| die $!;

    return $schema;

}

sub add_log {
    my ($who, $where, $type, $what) = @_;

    my $user = _schema->resultset('Users')->find_or_create( { email => $who } );
    my $channel =
      _schema->resultset('Channel')->find_or_create( { name => $where } );
    my $log = _schema->resultset('Log')->create(
        {
            channel_id => $channel,
            user_id    => $user,
#            ts         => '1980-01-01 12:00',
            entry      => $what,
            type       => $type,
        }
    );

}


1;
