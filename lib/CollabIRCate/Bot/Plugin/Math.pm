package CollabIRCate::Bot::Plugin::Math;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub answer {
  my $class = shift;
  my $question = shift;
  my $args = shift;
  my $from = $args->{from};

  if ( $question =~
        /^(what\s*[i']s\s:{0,1}){0,1}\s*([\d\+\-\s\*\/\.\,]+)([\s\=\?]+){0,1}$/
      )
    {
        $question =~ s/[^\d\+\-\*\/\^\s\.]//g;
        my $answer;
        eval "\$answer = $question;";
        return { answer => "the answer to $question is $answer" } if ( !$@ );
        return { answer => "nice try $from, $question is not valid" };
      }
  else {
    return;
  }

}

1;
