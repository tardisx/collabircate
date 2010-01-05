package CollabIRCate::Bot::Response;

use Moose;
use Carp qw/croak/;

=head1 NAME 

CollabIRCate::Bot::Response - class for IRC Bot responses.

=head1 SYNOPSIS

  my $response = CollabIRCate::Bot::Response->new();

  $response->add_public_response({channel => '#friends', text => 'hello'});
  $response->add_private_response({user => $user, text => 'not you'});

  $response->merge($some_other_response_object);

  $response->emit($irc);

=head1 DESCRIPTION

A bot may make multiple responses to a particular query. Some of them may be
public, some private. A CollabIRCate::Bot::Response object encapsulates them
in one place.

=cut

has 'public_response'  => ( is => 'rw', isa => 'ArrayRef' );
has 'private_response' => ( is => 'rw', isa => 'ArrayRef' );

<<<<<<< HEAD:lib/CollabIRCate/Bot/Response.pm
=head2 add_public_response

Add a public response. Requires a hash ref with channel and text keys.

=cut
=======
sub add_response {
    my $self = shift;
    my $args = shift || {};

    if ($args->{channel}) {
        return $self->add_public_response($args);
    }
    else {
        return $self->add_private_response($args);
    }
}

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

=head2 add_private_response 

Add a private response. Requires a hash ref containing a user object and 
the text to send.

=cut

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

=head2 merge

Merges this L<CollabIRCate::Bot::Response> object with another.

=cut

sub merge {
    my $self           = shift;
    my $other_response = shift;

    croak "not a CollabIRCate::Bot::Response object"
        unless ( ref $other_response eq 'CollabIRCate::Bot::Response' );
    $self->private_response(
        [   @{ $self->private_response || [] },
            @{ $other_response->private_response || [] }
        ]
    );
    $self->public_response(
        [   @{ $self->public_response || [] },
            @{ $other_response->public_response || [] }
        ]
    );
    return $self;
}

sub has_response {
    my $self = shift;

    if ( $self->private_response
        && @{ $self->private_response } )
    {
        return 1;
    }

    if ( $self->public_response
        && @{ $self->public_response } )
    {
        return 1;
    }
    return 0;
}

=head2 emit

Emits the responses, public and private, to an IRC server.

=cut

sub emit {
    my $self = shift;
    my $irc  = shift;

    return unless $self->has_response;

    if ( $self->private_response ) {
        foreach ( @{ $self->private_response } ) {
            my ( $user, $text ) = @$_;
            my $nick = $user->nick();
            $irc->yield( privmsg => $nick, $text );
         }
    }

    if ( $self->public_response ) {
        foreach ( @{ $self->public_response } ) {
            my ( $channel, $text ) = @$_;
            $irc->yield( privmsg => $channel, $text );
        }
    }

    return;

}

1;
