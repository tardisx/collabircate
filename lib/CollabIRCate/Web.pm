package CollabIRCate::Web;

use strict;
use warnings;

use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    # Routes
    my $r = $self->routes;

    # user auth stuff
    $r->route('/user/login')->to('user#login');
    $r->route('/user/logout')->to('user#logout');

    # user display stuff
    $r->route('/user/:uid')->to('user#show');

    # tokens
    $r->route('/token/link/:token')->to('token#link');
    $r->route('/token/upload/:token')->to('token#upload');

    # channels list
    $r->route('/channels')->to('channels#list');
    $r->route(
        '/channels/:channel/:date/:page',
        page => qr/\d+/,
        date => qr/today|\d\d\d\d\-\d\d\-\d\d/
    )->to('channels#show', page => 1, date => 'today');

    # Default route
    $r->route('/:controller/:action/:id')->to( 'root#welcome', id => 1 );
}

1;
