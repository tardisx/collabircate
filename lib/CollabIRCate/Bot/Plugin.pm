package CollabIRCate::Bot::Plugin;

use strict;
use warnings;

use CollabIRCate::Config;


=head1 NAME

CollabIRCate::Bot::Plugin - base class for plugins

=head2 DESCRIPTION

This base class does nothing useful except to hold this documenation
which tells you how to construct your plugin.

It is mandatory to provide a register() method, and any methods which
you register() for.

Your register() method returns a hashref, with one or more of the following
keys:

  public    => $coderef,
  addressed => $coderef,
  periodic  => [ 60, $coderef ],

The C<public> value is a reference to a subroutine to run when the Bot
sees any message in any channel it is on.

The C<addressed> value is a reference to a subroutine to run when the Bot
is specifically addressed, either publically or privately.

The C<periodic> value is an arrayref containing two values, the first is
the period (in seconds) determining how often the second coderef is actually
run.

As an example using all three of these, a plugin to collect per-channel
statistics would need to register a C<public> method to collect line by
line stats, and an C<addressed> method to answer questions about stats.

You may also return C<undef> from 'register', if your plugin cannot be loaded
(for example, if a perl module is not available).

=cut

use Carp qw/croak/;

sub register {

    croak "abstract register called!";
}

sub enabled {
    my $class = shift;
    return CollabIRCate::Config->plugin_enabled($class);
}

1;
