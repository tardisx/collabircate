package CollabIRCate::Bot;

# stuff for bots that matters!

use strict;
use warnings;

use CollabIRCate::Config;
use Carp qw/croak/;

use Exporter qw/import/;
our @EXPORT_OK = qw/bot_request get_tells del_tell/;
our @tell;

my $schema = CollabIRCate::Config->schema;

my @sorry_messages = (
    "sorry NICK, I'm not sure what you mean by 'MSG'",
    "NICK, I'm having trouble following you",
    "what do you mean by 'MSG', NICK?",
    "I'd love to help with 'MSG', but I'm not sure what it's about",
    "'MSG'? What do you mean NICK?",
);

my %timezones = (
    'london',   'Europe/London',      'adelaide',  'Australia/Adelaide',
    'brisbane', 'Australia/Brisbane', 'melbourne', 'Australia/Melbourne',
    'sydney',   'Australia/Sydney',
);

# someone made a request of our bot. let's deal with it and
# pass back a message indicating what we should say

sub bot_request {
    my $args     = shift;
    my $question = $args->{question};
    my $from     = $args->{from};
    my $channel  = $args->{channel};

    # we always need at least the question and from
    croak "bot_request called incorrectly, no question or from arguments"
        unless ( $question && $from );

    if ( $question =~ /time.*in.*\s(\w{4,})\?*/i ) {
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
        return [ $result, undef ];
    }

    elsif ( $question =~ s/^rot13:*\s*(.*)/$1/ ) {
        $question =~ y/A-Za-z/N-ZA-Mn-za-m/;
        return [ $question, undef ];
    }
    elsif ( $question =~ /help/i ) {
        return [ "I need help more than you right now $from", undef ];
    }
    elsif ( $question =~ /upload/ ) {
        my $chan
          = $schema->resultset('Channel')->search( { name => lc($channel) } )->next;
        my $chan_id;
        $chan_id = $chan->id if ($chan);
        my $req = $schema->resultset('Request')->create( {channel_id => $chan_id } );
        return [ "sending request ticket to $from", "you can upload your file at: " . $req->url . " or email it to " . $req->email ];
    }
    elsif ( $question
        =~ /^(what\s*[i']s\s:{0,1}){0,1}\s*([\d\+\-\s\*\/\.\,]+)([\s\=\?]+){0,1}$/
        )
    {
        $question =~ s/[^\d\+\-\*\/\^\s\.]//g;
        my $answer;
        eval "\$answer = $question;";
        return [ "the answer to $question is $answer", undef ] if ( !$@ );
        return [ "nice try $from, $question is not valid", undef ];
    }
    elsif ( $question =~ /^tell (\w+?)\s+(.*)/ ) {
        my $nick     = $1;
        my $tell_msg = $2;
        my $when     = time();
        push @tell, [ $nick, $tell_msg, $when ];
        return [ "will do $from", undef ];
    }

    return [ _sorry( $from, $question ), undef ];
}

sub get_tells {
    return @tell;
}

sub del_tell {
    my ( $who, $msg, $time ) = @_;
    my @new_tell = ();
    foreach (@tell) {
        my ( $this_who, $this_msg, $this_time ) = @$_;
        push @new_tell, [ $this_who, $this_msg, $this_time ]
            unless ( $this_who eq $who
            && $this_msg  eq $msg
            && $this_time eq $time );
    }
    @tell = @new_tell;
}

sub _sorry {
    my $nick   = shift;
    my $msg    = shift;
    my $number = int( rand( $#sorry_messages + 1 ) );
    my $return = $sorry_messages[$number];
    $return =~ s/NICK/$nick/;
    $return =~ s/MSG/$msg/;
    return $return;
}

=head1 NAME

CollabIRCate::Bot - Functions for the CollabIRCate Bot

=head1 SYNOPSIS

See L<CollabIRCate>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
