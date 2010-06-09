package CollabIRCate::Bot::Plugin::Hailo;

use strict;
use warnings;

use Hailo;

use base 'CollabIRCate::Bot::Plugin';

my $logger = CollabIRCate::Logger->get(__PACKAGE__);
my $hailo = Hailo->new(brain => 'hailo.db');    
my $last_channel = undef;

sub register {
    return {
        public    => \&collect,
        addressed => \&collect,
        periodic  => [ 60, \&spurt ],
    };
}

sub collect {
    my $user     = shift;
    my $channel  = shift;
    my $text     = shift;

    $last_channel = $channel;
    
    $logger->debug("collecting '$text' for hailo");
    $hailo->learn($text);
    $hailo->save();
    return;
}

sub spurt {
    my $irc = shift;
    return if (! $last_channel);
    # say stuff every now and then only
    return if (rand(1)<0.99);

    my $response = CollabIRCate::Bot::Response->new;
    $response->add_public_response(
        {   channel => $last_channel,
            text    => $hailo->reply
        });
    $response->emit($irc);
    return;
}

1;
