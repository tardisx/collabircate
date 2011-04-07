package CollabIRCate::Web::Channels;

use strict;
use warnings;

use Carp qw/croak/;

use CollabIRCate::DB::LogCombined::Manager;
use CollabIRCate::DB::Channel::Manager;
use CollabIRCate::DB::Channel;
use CollabIRCate::Logger;

use Data::Page;

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
    my $self    = shift;
    my $channel = $self->stash->{'channel'};
    my $page    = $self->stash->{'page'};
    my $date    = $self->stash->{'date'};
    my $pager   = Data::Page->new();

    $pager->current_page($page);

    # XXX this is an ugly hack and has to go
    $channel = '#' . $channel;

    my $channel_db;
    eval {
        $channel_db
            = CollabIRCate::DB::Channel->new( name => $channel )->load;
    };

    if ($@) {
        $logger->error("failed to load channel $channel - $@");
        $self->stash->{message} = 'bad channel';
        $self->stash->{logs}    = [];
        return;
    }

    # load the logs for this day
    my $now;
    if ($date eq 'today') {
        $now = DateTime->now();
    }
    else {
        my ($year, $month, $day) = ($date =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d)$/);
        croak "bad date $date" if (! $day);
        $now = DateTime->new(year => $year, month => $month, day => $day);
    }
    
    my $dt_begin = $now->truncate( to => 'day' );
    my $dt_end   = $dt_begin->clone->add( days => 1 );

    my $yesterday = $dt_begin->clone->subtract ( days => 1);
    
    my $query = [
        channel_id => $channel_db->id,
        ts         => { 'gt' => $dt_begin },
        ts         => { 'lt' => $dt_end }
    ];

    $pager->total_entries(
        CollabIRCate::DB::LogCombined::Manager->get_logs_count( query => $query ) );
    $pager->entries_per_page(100);

    my $logs = CollabIRCate::DB::LogCombined::Manager->get_logs(
        query   => $query,
        sort_by => 'ts',
        offset => $pager->skipped,
        limit  => $pager->entries_per_page,
    );

    $self->stash->{logs}    = $logs;
    $self->stash->{message} = 'hi';
    $self->stash->{pager}   = $pager;
    $self->stash->{tomorrow} = $dt_end->ymd;
    $self->stash->{yesterday} = $yesterday->ymd;
}

1;
