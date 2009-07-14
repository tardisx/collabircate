use strict;
use warnings;
use Test::More;

unless ($ENV{'COLLABIRCATE_INSIDE_HARNESS'}) {
    plan skip_all => 'Not inside harness';
}
else {
    plan tests => 4;
}

use POE qw(Wheel::SocketFactory);
use Socket;
use POE::Component::IRC;

my $bot1 = POE::Component::IRC->spawn(
    Flood        => 1,
    plugin_debug => 1,
);


POE::Session->create(
    package_states => [
        main => [qw(
            _shutdown 
            irc_001 
            irc_join
            irc_disconnected
        )],
    ],
);

$bot1->yield(register => 'all');
$bot1->yield(connect => {
    nick    => 'TestBot1',
    server  => '127.0.0.1',
    port    => 6668,
    ircname => 'Test test bot',
});

$poe_kernel->run();



sub irc_001 {
    my $irc = $_[SENDER]->get_heap();
    pass('Logged in');
    $irc->yield(join => '#testchannel');
}

sub irc_join {
    my ($heap, $sender, $who, $where) = @_[HEAP, SENDER, ARG0, ARG1];
    my $nick = ( split /!/, $who )[0];
    my $irc = $sender->get_heap();
    
    return if $nick ne $irc->nick_name();
    is($where, '#testchannel', 'Joined Channel Test');

    $heap->{joined}++;
    return if $heap->{joined} != 2;
    $bot1->yield(dcc => 'undefbot' => SEND => 'README' => 1024 => 5);
}

sub irc_disconnected {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    pass('irc_disconnected');
    $heap->{count}++;
    $kernel->yield('_shutdown') if $heap->{count} == 2;
}

sub _shutdown {
    my ($kernel, $reason) = @_[KERNEL, ARG0];
    fail($reason) if defined $reason;
    
    $kernel->alarm_remove_all();

    $bot1->yield('shutdown');

}

