package CollabIRCate::Bot::Plugin::WorldTime;

use strict;
use warnings;

use base 'CollabIRCate::Bot::Plugin';

sub register {
    return {
        public    => \&answer,
        addressed => \&answer
    };
}

my @timezones;

BEGIN {

    # read in zone.tab
    open( my $fh, "<", "/usr/share/zoneinfo/zone.tab" )
        || die "$! in the ass";
    while (<$fh>) {
        next if /^#/;

# AQ      -7750+16636     Antarctica/McMurdo      McMurdo Station, Ross Island
        my ( undef, undef, $tz ) = split /\s+/;
        push @timezones, $tz;
    }
    close $fh;
}

sub answer {
    my $user     = shift;
    my $channel  = shift;
    my $question = shift;

    if (   $question =~ /time.*in\s+([\w\/]{3,})\s*(now)?/i
        || $question =~ /^.{0,2}\b([\w\/]{3,}) time\s*(now)?/i )
    {

        my $place = lc($1);
        my $result;
        my @possible = ();
        foreach my $a_tz (@timezones) {
            if ( $a_tz =~ /$place/i ) {
                push @possible, $a_tz;
            }
        }
        my $num_results = scalar @possible;
        if ( $num_results == 1 ) {
            $ENV{TZ} = $possible[0];
            my $tmp = `date`;
            chomp $tmp;
            $tmp =~ s/\s\w\w\w\s\d\d\d\d$//;
            $result = $tmp;
        }
        elsif ( $num_results > 1 ) {
            $result = 'sorry, not sure if you mean ';
            my $max_or = 3;
            my $idx_to_show
                = $num_results > $max_or ? $max_or - 1 : $num_results - 1;
            my @list = @possible[ 0 .. $idx_to_show ];
            $result .= join( ' or ', @list );
            $result .= " or " . ( $num_results - $max_or ) . " others"
                if ( $num_results > $max_or );
        }
        else {
            $result = 'sorry, don\'t know about the time in ' . $place;
        }

        my $response = CollabIRCate::Bot::Response->new;
        $response->add_response(
            {   channel => $channel,
                user    => $user,
                text    => $result
            }
        );
        return $response;
    }
    else {
        return;
    }
}

1;
