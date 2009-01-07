package CollabIRCate::View::Site;

use strict;
use base 'Catalyst::View::TT';
use URI::Find;

__PACKAGE__->config({
    INCLUDE_PATH => [
        CollabIRCate->path_to( 'root', 'src' ),
        CollabIRCate->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0
});


my $finder = URI::Find->new(sub {
    my ($uri, $orig_uri) = @_;
    return qq|<a href="$uri">$orig_uri</a>|;
});

sub makelinks {
    my $text = shift;
    $finder->find(\$text);
#    $text =~ s/http:/LINK:/g;
    return $text;
}


__PACKAGE__->config({
    FILTERS => {
        'makelinks' => \&makelinks,
        },
    }
                  );
    

=head1 NAME

CollabIRCate::View::Site - Catalyst TTSite View

=head1 SYNOPSIS

See L<CollabIRCate>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

