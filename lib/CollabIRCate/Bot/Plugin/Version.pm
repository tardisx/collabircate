package CollabIRCate::Bot::Plugin::Version;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

=head2 answer

We read the main C<CollabIRCate.pm> file manually here, since we don't
want to C<require> or C<use> it from the bot - it does a heap of unwanted
Catalyst things.

=cut

sub answer {
  my ($class, $question, $args) = @_;

  unless ( $question =~ /version/i ) {
    return;
  }
 
  my $answer = eval {
    open (my $fh, "<", "lib/CollabIRCate.pm") || die "can't open file\n";
    my $line;
    while ($line = <$fh>) {
      next unless $line =~ /\$VERSION\s*\=\s*['"]([\d\.]+)['"]/;
      my $version = $1;
      return { answer => "I am version $version" };
    }
    die "didn't find the version number\n";
  };

  if ($@) {
    return { answer => "I don't know my own version :-( ($@)" };
  } 
  else {
    return $answer;
  }

}

1;
