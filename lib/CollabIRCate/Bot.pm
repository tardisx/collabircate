package CollabIRCate::Bot;

use strict;
use warnings;

use CollabIRCate::Logger;
use CollabIRCate::Config;
use CollabIRCate::Bot::Response;

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

our $logger = CollabIRCate::Logger->get(__PACKAGE__);

my @plugins = plugins();

# XXX override plugins 
@plugins = (    #'CollabIRCate::Bot::Plugin::Statistics',
    'CollabIRCate::Bot::Plugin::Rot13',
    'CollabIRCate::Bot::Plugin::Math',
    'CollabIRCate::Bot::Plugin::WorldTime'
);

# someone said something to anyone, the bot 'heard' it
sub bot_heard {
    my $who     = shift;
    my $channel = shift;
    my $message = shift;

    # check plugins
    my $all_responses = CollabIRCate::Bot::Response->new();
    $logger->debug("considering plugins for '$message' - heard publically");
    
    foreach my $plugin (@plugins) {
        if ( $plugin->register->{public} ) {
            $logger->debug("checking $plugin");
            my $response = &{ $plugin->register->{public} }( $who, $channel,
                $message );

            # XXX do something with the response
            if ($response) {
                $logger->debug("received response");
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
    $logger->debug("considering plugins for '$message' - addressed to me");
    
    foreach my $plugin (@plugins) {
        if ( $plugin->register->{addressed} ) {
            $logger->debug("checking $plugin");
            my $response
                = &{ $plugin->register->{addressed} }( $who, $channel,
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
