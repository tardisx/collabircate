package CollabIRCate::Bot;

use strict;
use warnings;

use CollabIRCate::Config;
use Carp qw/croak/;
use Module::Pluggable require => 1;

use Exporter qw/import/;

=head1 NAME

CollabIRCate::Bot

=head1 SYNOPSIS

XXX

=head1 DESCRIPTION

The brains of the CollabIRCate bot.

=cut

our @EXPORT_OK = qw/bot_request get_tells del_tell/;
our @tell;

my $schema = CollabIRCate::Config->schema;
my @plugins = plugins();

my @sorry_messages = (
    "sorry NICK, I'm not sure what you mean by 'MSG'",
    "NICK, I'm having trouble following you",
    "what do you mean by 'MSG', NICK?",
    "I'd love to help with 'MSG', but I'm not sure what it's about",
    "'MSG'? What do you mean NICK?",
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

    my $result;

    # check plugins first
    foreach my $plugin (@plugins) {
      if (my $result = $plugin->answer($question,
                                       { from => $from })) {
        return [ $result->{answer}, undef ];
      }
    }

    if ( $question =~ /upload/ ) {
        my $chan =
          $schema->resultset('Channel')->search( { name => lc($channel) } )
          ->next;
        my $chan_id;
        $chan_id = $chan->id if ($chan);
        my $req =
          $schema->resultset('Request')->create( { channel_id => $chan_id } );
        return [
            "sending request ticket to $from",
            "you can upload your file at: "
              . $req->url
              . " or email it to "
              . $req->email
        ];
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

The L<CollabIRCate::Bot> helps us deal with users, specifically
L<CollabIRCate::Bot::Users>, who may or may not be identified real
users of the CollabIRCate system.

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
