package CollabIRCate::Web;

use strict;
use warnings;

use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->plugin('simple_session');

    # Routes
    my $r = $self->routes;

    # user auth stuff
    $r->route('/user/login')->to('user#login');
    $r->route('/user/logout')->to('user#logout');

    # tokens
    $r->route('/token/:token')->to('token#index');

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
