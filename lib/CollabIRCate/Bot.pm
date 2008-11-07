package CollabIRCate::Bot;

# stuff for bots that matters!

use strict;
use warnings;

use Exporter qw/import/;
our @EXPORT_OK = qw/bot_request/;

my @sorry_messages = ( "sorry NICK, I'm not sure what you mean by 'MSG'",
		       "NICK, I'm having trouble following you",
		       "what do you mean by 'MSG', NICK?",
		       "I'd love to help with 'MSG', but I'm not sure what it's about",
		       "'MSG'? What do you mean NICK?",
		       );

my %timezones = ( 
		  'london', 'Europe/London',
		  'adelaide', 'Australia/Adelaide',
		  'brisbane', 'Australia/Brisbane',
		  'melbourne', 'Australia/Melbourne',
		  'sydney', 'Australia/Sydney',
		  );

# someone made a request of our bot. let's deal with it and
# pass back a message indicating what we should say

sub bot_request {
    my $question = shift;
    my $from = shift;

    
    if ($question =~ /time.*in.*\s(\w{4,})\?*/i) {
	my $place = lc ($1);
	my $result;
	if (defined $timezones{$place}) {
	    $ENV{TZ} = $timezones{$place};
	    my $tmp = `date`;
	    chomp $tmp;
	    $tmp =~ s/\s\w\w\w\s\d\d\d\d$//;
	    $result = $tmp;
	}
	else {
	    $result = 'sorry, don\'t know about the time in ' . $place;
        }
	return $result;
    }

    elsif ($question =~ s/^rot13:*\s*(.*)/$1/) {
	$question =~ y/A-Za-z/N-ZA-Mn-za-m/;
	return $question;
    }
    elsif ($question =~ /help/i) {
	return "I need help more than you right now $from";
    }
    elsif ($question =~ /upload/) {
	return "upload ticket would be sent to you $from, if it were implemented";
    }

    return _sorry($from, $question);
}


sub _sorry {
    my $nick = shift;
    my $msg = shift;
    my $number = int(rand($#sorry_messages+1));
    my $return = $sorry_messages[$number];
    $return =~ s/NICK/$nick/;
    $return =~ s/MSG/$msg/;
    return $return;
}
    

1;
