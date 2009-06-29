package CollabIRCate::Bot::Plugin::Help;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub answer {
  my ($class, $question, $args) = @_;

  unless ( $question =~ /help/i ) {
    return;
  }

  my $from = $args->{from};

  return { answer => "I need help more than you right now $from" };

}

1;
