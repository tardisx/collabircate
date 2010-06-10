package CollabIRCate::Colours;

use strict;
use warnings;

my @colours = qw/ ff0000 00ff00 0000ff
                  ffff00 ff00ff 00ffff /;

sub new {
    my $self = {};
    $self->{current} = {};
    $self->{left}    = [@colours];
    bless $self;
    return $self;
}

sub colour {
    my $self = shift;
    my $value = shift;

    return $self->{current}->{$value}
        if defined $self->{current}->{$value};

    my $colour = shift @{ $self->{left} };
    $self->{current}->{$value} = $colour;

    if (! @{ $self->{left} } ) {
        $self->{left} = [@colours];  # start again
    }

    return $colour;
}

1;
