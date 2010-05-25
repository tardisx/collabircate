package CollabIRCate::Bot;

use strict;
use warnings;

use CollabIRCate::Logger;
use CollabIRCate::Config;
use CollabIRCate::Bot::Response;

use Carp qw/croak/;
use Module::Pluggable require => 1;

=head1 NAME

CollabIRCate::Bot - Implement the brains of an IRC bot.

=head1 SYNOPSIS

  my $bot = CollabIRCate::Bot->new();

=head1 DESCRIPTION

Encapsulates a bot.

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Moose;

my @plugins = plugins();

our $logger = CollabIRCate::Logger->get(__PACKAGE__);

# XXX override plugins
@plugins = (

    # 'CollabIRCate::Bot::Plugin::Statistics',
    'CollabIRCate::Bot::Plugin::Rot13',
    'CollabIRCate::Bot::Plugin::Math',
    'CollabIRCate::Bot::Plugin::WorldTime'
);

# someone said something to anyone, the bot 'heard' it

=head2 bot_heard

Tell the Bot that it heard something, what it heard and who said it.

=cut

sub bot_heard {
    my $self    = shift;
    my $user    = shift;
    my $channel = shift;
    my $message = shift;

    # check plugins
    my $all_responses = CollabIRCate::Bot::Response->new();
    $logger->debug("considering plugins for '$message' - heard publically");

    foreach my $plugin (@plugins) {
        if ( $plugin->register->{public} ) {
            $logger->debug("checking $plugin");
            my $response = &{ $plugin->register->{public} }( $user, $channel,
                $message );

            if ($response) {
                $logger->debug("received response");
                $all_responses->merge($response);
            }
        }
    }
    return $all_responses;
}

=head2 bot_addressed

Tell the Bot that it someone told it something, either directly (privately)
or addressed by name in a channel.

=cut

sub bot_addressed {
    my $self    = shift;
    my $user    = shift;
    my $channel = shift;    # undef if private
    my $message = shift;

    my $all_responses = CollabIRCate::Bot::Response->new();
    $logger->debug("considering plugins for '$message' - addressed to me");

    foreach my $plugin (@plugins) {
        if ( $plugin->register->{addressed} ) {
            $logger->debug("checking $plugin");
            my $response
                = &{ $plugin->register->{addressed} }( $user, $channel,
                $message );
            if ($response) {
                $logger->debug("received a response");
                $all_responses->merge($response);
            }
        }
    }

    return $all_responses;
}

1;
