package CollabIRCate::DB::LogCombined;

use strict;
use warnings;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

__PACKAGE__->meta->setup(
    table => 'log_combined',

    columns => [
        id => { type => 'serial',    not_null => 1, primary_key => 1 },
        ts => { type => 'timestamp', not_null => 1 },
        entry_type  => { type => 'text', not_null => 1 },
        channel_id  => { type => 'integer', not_null => 1 },
        irc_user_id => { type => 'integer', not_null => 1 },
        type        => { type => 'text',    not_null => 0 }, # entry_type = log
        entry       => { type => 'text',    not_null => 0 }, # entry_type = log
        filename    => { type => 'text',    not_null => 0 }, # entry_type = file
        mime_type   => { type => 'text',    not_null => 0 }, # entry_type = file
        size        => { type => 'integer', not_null => 0 }, # entry_type = file
        
    ],

    foreign_keys => [
        channel => {
            class       => 'CollabIRCate::DB::Channel',
            key_columns => { channel_id => 'id' },
        },
        irc_user => {
            class       => 'CollabIRCate::DB::IRCUser',
            key_columns => { irc_user_id => 'id' },
        },
    ],

    
);

=head2 nick

Return the nick for this log entry.

=cut

sub nick {
    my $self = shift;
    my $irc_user = $self->irc_user;

    my @nicks = $irc_user->nicks();
    foreach (reverse @nicks) { 
      return $_->nick if ($_->ts <= $self->ts);
    }
    return 'BADNICK';
}

sub nice_ts {
    my $self = shift;
    my $ts = $self->ts;
    return $ts->strftime("%F %H:%M");
}

1;
