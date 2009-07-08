package CollabIRCate::Bot::Plugin::Banter;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub answer {
    my $class    = shift;
    my $question = shift;
    my $args     = shift;
    my $from     = $args->{from};

    if (   $question =~ /fuck off/i
        || $question =~ /get fucked/i
        || $question =~ /hate.*you/i
        || $question =~ /you suck/i
        || $question =~ /you.*are.*(stupid|dumb|ugly)/i )
    {
        return { answer => "same to you $from" };
    }

    if ( $question =~ /\b(hello|greetings|g'day|gday|hi|hi there|good morning|good afternoon)\b/i ) {
        return { answer => "hello $from" };
    }

    if ( $question =~ /\b(thanks|cheers|awesome)\b/i ) {
        return { answer => "no problem $from" };
    }

    if ( $question =~ /\b(bye|goodbye|ciao)\b/i ) {
        return { answer => "goodbye $from" };
    }

    if ( $question =~ /\b(how are you)\b/i ) {
        return { answer => "just fine thanks $from" };
    }

    if ( $question =~ /\b(your mother)\b/i ) {
        return { answer => "let me tell you about my mother *BLAM*" };
    }

    if ( $question =~ /good.*(morning|afternoon|evening|night)/i ) {
        return { answer => "and a very good $1 to you to" };
    }

    if ( $question =~ /thanks,?\s*(\w+)(.*?)/i ) {
        my $word = $1;
        my $answer;
        my ( $first_bit, $last_bit ) = $word =~ /^([^aeiou]+)(.*)$/;
        if ($last_bit) {
            $answer = "th$last_bit";
        }
        else {
            $answer = "th$word";
        }
        return { answer => $answer };
    }
    return;
}

1;
