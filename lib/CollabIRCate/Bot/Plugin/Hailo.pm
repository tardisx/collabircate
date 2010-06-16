package CollabIRCate::Bot::Plugin::Hailo;

use strict;
use warnings;

use Hailo;
use CollabIRCate::Config;
use CollabIRCate::Logger;

use base 'CollabIRCate::Bot::Plugin';

my $logger = CollabIRCate::Logger->get(__PACKAGE__);
my $hailo_brains = {};
my $last_channel = undef;
my $channel_noise = {};

sub register {
    return {
        public    => \&collect,
        addressed => \&collect_and_emit,
        periodic  => [ 60, \&spurt ],
    };
}

sub collect_and_emit {
    my $user     = shift;
    my $channel  = shift;
    my $text     = shift;

    if ($text =~ /^say something/) {
        my $hailo = _get_brain($channel);

        my $response = CollabIRCate::Bot::Response->new;
        $response->add_public_response(
            {   channel => $channel,
                text    => $hailo->reply(),  # this could supply $text
            });
        return $response;
    }
    else {
        # just collect as usual
        collect($user, $channel, $text);
    }
}

sub collect {
    my $user     = shift;
    my $channel  = shift;
    my $text     = shift;

    $last_channel = $channel;

    $channel_noise->{$channel}++;

    my $hailo = _get_brain($channel);

    $logger->debug("collecting '$text' for hailo");
    $hailo->learn($text);
    $hailo->save();
    return;
}

sub spurt {
    my $irc = shift;

    foreach my $channel (keys %$channel_noise) {
        # say stuff every now and then only
        my $chance = _noise_to_chance($channel_noise->{$channel});
        $channel_noise->{$channel} = 0;
        next if (rand(1) > $chance);

        my $hailo = _get_brain($channel);

        my $response = CollabIRCate::Bot::Response->new;
        $response->add_public_response(
            {   channel => $channel,
                text    => $hailo->reply
            });
        $response->emit($irc);
    }

    return;
}

sub _noise_to_chance {
    my $messages = shift;

    my $noisy =      CollabIRCate::Config->config()->{plugin_hailo_noisy_messages} || 10;
    my $max_chance = CollabIRCate::Config->config()->{plugin_hailo_noisy_chance}   || 0.5;
    my $min_chance = CollabIRCate::Config->config()->{plugin_hailo_quiet_chance}   || 0.01;
    die "max < min ?" if ($max_chance < $min_chance);
    my $diff = $max_chance - $min_chance;

    my $noise = $messages / $noisy;
    $noise = 1 if ($noise > 1);

    my $chance = $min_chance + $noise * $diff;
    return $chance;
}

sub _get_brain {
    my $channel = shift;
    unless (CollabIRCate::Config->config()->{plugin_hailo_db_per_channel}) {
        $channel = 'all';
    }
    return $hailo_brains->{$channel} if ( $hailo_brains->{$channel} );

    $hailo_brains->{$channel} = Hailo->new(brain => 'hailo_' . $channel . '.db');
    return $hailo_brains->{$channel};
}

1;
