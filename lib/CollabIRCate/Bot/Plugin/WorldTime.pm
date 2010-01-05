package CollabIRCate::Bot::Plugin::WorldTime;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub register {
  return {
    public => \&answer,
    addressed => \&answer
  };
}

my %timezones = (
    'london',   'Europe/London',      'adelaide',  'Australia/Adelaide',
    'brisbane', 'Australia/Brisbane', 'melbourne', 'Australia/Melbourne',
    'sydney',   'Australia/Sydney',
);

sub answer {
  my $user    = shift;
  my $channel = shift;
  my $question  = shift;

    if (   $question =~ /time.*in.*\s(\w{4,})\?*/i
        || $question =~ /(\w{4,}) time/i )
    {

        my $place = lc($1);
        my $result;
        if ( defined $timezones{$place} ) {
            $ENV{TZ} = $timezones{$place};
            my $tmp = `date`;
            chomp $tmp;
            $tmp =~ s/\s\w\w\w\s\d\d\d\d$//;
            $result = $tmp;
        }
        else {
            $result = 'sorry, don\'t know about the time in ' . $place;
        }

        my $response = CollabIRCate::Bot::Response->new;
        $response->add_response({channel => $channel,
                                 user => $user,
                                 text => $result});
        return $response;
    }
    else {
        return;
    }
}

1;
