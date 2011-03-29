package CollabIRCate::Bot::Plugin::Math;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

=head2 register

Registers the Math plugin.

=cut

sub register {
    return {
        public    => \&answer,
        addressed => \&answer
    };
}

=head2 answer

Answers a math question.

=cut

sub answer {
    my $user    = shift;
    my $channel = shift;
    my $msg     = shift;

#    die "who $who where $channel msg $msg";

    if ( $msg
        =~ /^(what\s*[i']s\s:{0,1}){0,1}\s*([\d\+\-\s\*\/\.\,]+)([\s\=\?]+){0,1}$/
        )
    {
        $msg =~ s/[^\d\+\-\*\/\^\s\.]//g;
        my $answer = eval "$msg";

        my $response = CollabIRCate::Bot::Response->new;
        if (!$@) {
            $response->add_response({channel => $channel,
                                     user => $user,
                                     text => "the answer is $answer"});
        }
        else {
            $response->add_response({channel => $channel,
                                     user => $user,
                                     text => "nice try, $msg is not valid"});
        }
        return $response;
    }
    else {
        # not a math question
        return;
    }


}

1;
