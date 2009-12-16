package CollabIRCate::Bot::Response;

use Moose;
use Carp qw/croak/;

# The response that a bot makes may involve zero or more channels, and
# zero or more private messages. This package encapsulates such responses.

has 'public_response'  => ( is => 'rw', isa => 'ArrayRef' );
has 'private_response' => ( is => 'rw', isa => 'ArrayRef' );

sub add_public_response {
    my $self = shift;
    my $args = shift || {};

    my $channel = $args->{channel};
    my $text    = $args->{text};

    croak "no channel for public response" unless $channel;
    croak "no text for public response"    unless $text;

    my $current = $self->public_response || [];
    $self->public_response( [ ( @{$current}, [ $channel, $text ] ) ] );
    return $self;
}

sub add_private_response {
    my $self = shift;
    my $args = shift || {};

    my $user = $args->{user};
    my $text = $args->{text};

    croak "no user for private response" unless $user;
    croak "no text for private response" unless $text;

    croak "not a CollabIRCate::Bot::Users object"
        unless ( ref $user eq 'CollabIRCate::Bot::Users' );

    my $current = $self->private_response || [];
    $self->private_response( [ ( @{$current}, [ $user, $text ] ) ] );
    return $self;
}
1;
