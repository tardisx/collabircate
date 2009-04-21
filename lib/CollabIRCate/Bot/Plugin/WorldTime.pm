package CollabIRCate::Bot::Plugin::WorldTime;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

my %timezones = (
    'london',   'Europe/London',      'adelaide',  'Australia/Adelaide',
    'brisbane', 'Australia/Brisbane', 'melbourne', 'Australia/Melbourne',
    'sydney',   'Australia/Sydney',
);

sub answer {
  my ($class, $question) = @_;

  unless ( $question =~ /time.*in.*\s(\w{4,})\?*/i ) {
    return undef;
  }

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
  return { answer => $result };
}

1;
