package CollabIRCate::Bot::Response;

use Moose;

# The response that a bot makes may involve zero or more channels, and
# zero or more private messages. This package encapsulates such responses.


has 'public_response' => (is => 'rw', isa => 'ArrayRef');
has 'private_response' => (is => 'rw', isa => 'ArrayRef');

1;
