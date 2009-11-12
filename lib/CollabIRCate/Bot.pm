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

our @EXPORT_OK = qw/bot_addressed bot_heard/;
our @tell;

my $schema = CollabIRCate::Config->schema;
my @plugins = plugins();

@plugins = ('CollabIRCate::Bot::Plugin::Statistics');

my @sorry_messages = (
    "sorry NICK, I'm not sure what you mean by 'MSG'",
    "NICK, I'm having trouble following you",
    "what do you mean by 'MSG', NICK?",
    "I'd love to help with 'MSG', but I'm not sure what it's about",
    "'MSG'? What do you mean NICK?",
    "an interesting concept I'm sure, NICK",
    "NICK, that makes little sense to me :-(",
    "I'm not sure what you mean NICK",
    "I don't have enough brains to work that out, NICK",
);

# someone said something to anyone, the bot 'heard' it
sub bot_heard {
    my $who     = shift;
    my $channel = shift;
    my $message = shift;

    # check plugins
    foreach my $plugin (@plugins) {
        if ($plugin->register->{public}) {
            my $response = &{ $plugin->register->{public} }($who, $channel, $message);
            # XXX do something with the response
            warn $response;
        }
    }
}

# someone said something to the bot (publically or privately)
sub bot_addressed {
    my $who     = shift;
    my $channel = shift;    # undef if private
    my $message = shift;

    # check plugins first
    foreach my $plugin (@plugins) {
        if ($plugin->register->{addressed}) {
            my $response = &{ $plugin->register->{addressed} }($who, $channel, $message);
            return $response;
        }
    }

=pod

    # this needs to go into a plugin
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

=cut

    # XXX should be a response
    return [ _sorry( $who, $message ), undef ];
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
