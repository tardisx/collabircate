package CollabIRCate::DB::Token;

use strict;
use warnings;

use Digest::MD5;
use Time::HiRes qw/time/;
use Storable;

use CollabIRCate::DB::Channel;
use CollabIRCate::DB::IRCUser;

use Carp qw/croak/;

use base 'CollabIRCate::DB::Object';

my $expires = 3600;    # XXX should be configurable??

__PACKAGE__->meta->setup(
    table => 'token',

    columns => [
        token   => { type => 'text',      not_null => 1, primary_key => 1 },
        expires => { type => 'timestamp', not_null => 1 },
        type    => { type => 'text',      not_null => 1 },
        data    => { type => 'text',      not_null => 1 },
    ],
);

# XXX parameters passed in the data part of the these tokens should
# be made consistent, sometimes we use id, othertimes strings.

=head2 new_link_token

Create a token to link an IRC user to a real user.

=cut

sub new_link_token {
    my $class    = shift;
    my $irc_user = shift;

    croak "called as object method" if ( ref $class );

    my $md5 = Digest::MD5->new();
    $md5->add($$);
    $md5->add( time() );
    $md5->add($irc_user);

    my $self = __PACKAGE__->new(
        token   => $md5->hexdigest,
        expires => time() + $expires,
        type => 'link',
        data    => $irc_user,
    );

    return $self;
}

=head2 new_upload_token

Creates a token for a file upload. Potential file uploads require an IRC user
and a channel destination for the upload.

=cut

sub new_upload_token {
    my $class       = shift;
    my $channel_id  = shift;    # a channel id
    my $irc_user_id = shift;    # an IRC user id

    croak "called as object method" if ( ref $class );

    my $md5 = Digest::MD5->new();
    $md5->add($$);
    $md5->add( time() );
    $md5->add($channel_id);
    $md5->add($irc_user_id);

    my $self = __PACKAGE__->new(
        token   => $md5->hexdigest,
        expires => time() + $expires,
        type    => 'upload',
        data    => "$channel_id|$irc_user_id",
    );

    return $self;
}

sub channel {
    my $self = shift;
    if ($self->type eq 'upload') {
        my (@data) = split /|/, $self->data();
        return CollabIRCate::DB::Channel->new( id => $data[0] )->load();
    }
    die "unimplemented";
}

sub ircuser {
    my $self = shift;
    if ($self->type eq 'upload') {
        my (@data) = split /|/, $self->data();
        return CollabIRCate::DB::IRCUser->new( id => $data[1] ) ->load();
    }
    die "unimplemented";
}

1;
