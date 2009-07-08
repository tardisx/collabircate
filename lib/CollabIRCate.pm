package CollabIRCate;

use strict;
use warnings;

use 5.8.0;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
our $VERSION = '0.03';

# Configure the application.
#
# Note that settings in collabircate.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'CollabIRCate' );

# Start the application
__PACKAGE__->setup();


=head1 NAME

CollabIRCate - free, open-source collaboration tool

=head1 SYNOPSIS

    script/collabircate_server.pl

=head1 DESCRIPTION

CollabIRCate is a free, open-source collaboration tool. It leverages
existing services and environments, IRC, mail, the web, rather than
trying to force you to learn Yet Another Tool.

It is completely self-contained, you need nothing but a unix-like
system with perl to run it on. The package contains an IRC server, but
you can run it on an existing IRC server if you wish to use your
existing infrastructure, or a public server.

The software provides a powerful way to share ideas with others, using
a unique combination of both instant and more traditional messaging
technologies. Participation is via standard, intuitive techniques.

=head1 SEE ALSO

L<CollabIRCate::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Justin Hawkins

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
