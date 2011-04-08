package CollabIRCate::DB::LogCombined;

use strict;
use warnings;
use URI::Find;
use URI::Escape qw/uri_escape/;
use LWP::Simple qw/get/;
use CollabIRCate::Config;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

# Get the config
my $config = CollabIRCate::Config->config();
# Create our URI Finder
my $uri_finder = URI::Find->new(\&_process_uri);
# And a global for the thumbnail data
my @url_html;

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

=head2 output_html

Output this row as a HTML fragment.

=cut

sub output_html {
    my $self = shift;
    @url_html = ();
    if ($self->entry_type eq 'log') {
        # log stuff
        my $output = $self->nice_ts . ": ";
        my $text   = $self->entry;
        $uri_finder->find(\$text);
        $output .= $text . "<br />";
        if (@url_html) { 
          $output .= "<span>" . join('', @url_html) . "</span>";
        }
        return $output;
    }
    elsif ($self->entry_type eq 'file') {
        die "dunno yet";
    }
    else {
        die "can't handle " . $self->entry_type;
    }
}


sub _process_uri {
    my ($uri) = shift;

    if ($config->{http_thumboo_api}) {
      my $thumboo_api = $config->{http_thumboo_api};
      my $thumoo_params = "u=".uri_escape("http://collabircate.eatmorecode.com/").
                          "&su=".uri_escape($uri)."&c=medium&api=".$thumboo_api;
      my $url = "http://counter.goingup.com/thumboo/snapshot.php?".$thumoo_params;
      push @url_html, get $url;
    }

    return "<a href=\"$uri\">$uri</a>";
}


1;
