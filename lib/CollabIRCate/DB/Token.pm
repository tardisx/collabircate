package CollabIRCate::DB::Token;

use strict;
use warnings;

use Digest::MD5;
use Time::HiRes qw/time/;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

my $expires = 3600;    # XXX should be configurable??

__PACKAGE__->meta->setup(
    table => 'token',

    columns => [
        token   => { type => 'text',      not_null => 1, primary_key => 1 },
        expires => { type => 'timestamp', not_null => 1 },
        data    => { type => 'text',      not_null => 1 },
    ],
);

sub new_link_token {
    my $class = shift;
    my $link  = shift;    # an IRC user

    croak "called as object method" if ( ref $class );

    my $md5 = Digest::MD5->new();
    $md5->add($$);
    $md5->add(time());
    $md5->add($link);
    
    my $self  = __PACKAGE__->new(
        token   => $md5->hexdigest,
        expires => time() + $expires,
        data    => $link,
    );

    return $self;
}

1;
