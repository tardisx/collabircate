package CollabIRCate::Web::Channels;

use strict;
use warnings;

use Carp qw/croak/;

use CollabIRCate::DB::Log::Manager;
use CollabIRCate::DB::Channel::Manager;
use CollabIRCate::DB::Channel;
use CollabIRCate::Logger;

my $logger = CollabIRCate::Logger->get(__PACKAGE__);

use base 'Mojolicious::Controller';

=head2 list

List all the channels.

=cut

sub list {
    my $self = shift;

    my $channels = CollabIRCate::DB::Channel::Manager->get_channels();

    $self->stash->{channels} = $channels;
}

=head2 show

Show the log of a channel.

=cut

sub show {
    my $self = shift;
    my $channel = $self->stash->{'channel'};

    # XXX this is an ugly hack and has to go
    $channel = '#'.$channel;
    
    my $channel_db;
    eval {
        $channel_db = CollabIRCate::DB::Channel->new(name=>$channel)->load;
    };

    if ($@) {
        $logger->error("failed to load channel $channel - $@");
        $self->stash->{message} = 'bad channel';
        $self->stash->{logs}    = [];
        return;
    }

    # load the logs
    my $logs = CollabIRCate::DB::Log::Manager->get_logs(
        query => [ channel_id => $channel_db->id ],
        sort_by => 'ts',
    );
    $self->stash->{logs} = $logs;
    $self->stash->{message} = 'hi';
        
}

1;
