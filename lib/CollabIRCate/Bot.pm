package CollabIRCate::Bot;

use strict;
use warnings;

use CollabIRCate::Config;
use Carp qw/croak/;
use Module::Pluggable require => 1;

use Exporter qw/import/;


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

our @EXPORT_OK = qw/bot_addressed bot_heard/;
our @tell;

my $schema = CollabIRCate::Config->schema;
my @plugins = plugins();

@plugins = ('CollabIRCate::Bot::Plugin::Statistics',
            'CollabIRCate::Bot::Plugin::Rot13');

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
    my $all_responses = CollabIRCate::Bot::Response->new();
    foreach my $plugin (@plugins) {
        if ($plugin->register->{public}) {
            my $response = &{ $plugin->register->{public} }($who, $channel, $message);
            # XXX do something with the response

            if ($response) {
                $all_responses->merge($response);
            }
        }
    }
    return $all_responses;
}

# someone said something to the bot (publically or privately)
sub bot_addressed {
    my $who     = shift;
    my $channel = shift;    # undef if private
    my $message = shift;

    my $all_responses = CollabIRCate::Bot::Response->new();
    foreach my $plugin (@plugins) {
        if ($plugin->register->{addressed}) {
            my $response = &{ $plugin->register->{addressed} }($who, $channel, $message);
            $all_responses->merge($response) if ($response);
        }
    }

    return $all_responses;
}

1;
