package CollabIRCate::DB::File;

use strict;
use warnings;

use Carp qw/croak/;
use CollabIRCate::Config;
use File::Spec::Functions qw/catfile catdir/;

use base 'CollabIRCate::DB::Object';

my $config = CollabIRCate::Config->config();

__PACKAGE__->meta->setup(
    table => 'file',

    columns => [
        id => { type => 'serial',    not_null => 1, primary_key => 1 },
        ts => { type => 'timestamp', not_null => 1 },
        channel_id  => { type => 'integer', not_null => 1 },
        irc_user_id => { type => 'integer', not_null => 1 },
        filename    => { type => 'text',    not_null => 1 },
        mime_type   => { type => 'text',    not_null => 1 },
        size        => { type => 'integer', not_null => 1 },
    ],

    foreign_keys => [
        channel => {
            class       => 'CollabIRCate::DB::Channel',
            key_columns => { channel_id => 'id' },
        },
        irc_user => {
            class       => 'CollabIRCate::DB::IRCUser',
            key_columns => { irc_user_id => 'id' },
        },
    ],

);

=head2 path

Return the filesystem path for this file.

=cut

sub path {
    my $self  = shift;
    my $id    = $self->{id};
    my $root  = $config->{file_store_path};
    my $depth = $config->{file_store_depth};

    croak "no depth set?" unless $depth;
    croak "no root set?"  unless $root;
    
    #      1 =>  001 => file 0/0/1/1
    #  34567 =>  567 => file 5/6/3/34567
    # 932731 =>  731 => file 7/3/1/932731

    my @paths = split //, substr( sprintf( "%0${depth}d", $id ), -$depth );

    for ( my $i = 0; $i <= $#paths ; $i++) {
        my $part_path = catdir( $root, @paths[ 0 .. $i ] );
        unless ( -d $part_path ) {
            warn "MAKING! $part_path";
            mkdir $part_path || croak "could not create $part_path: $!";
        }
    }

    return catfile( $root, @paths, $id );
}

1;
