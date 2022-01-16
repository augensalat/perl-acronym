package Exception::HTTP::BadRequest;

use base 'Exception::HTTP';

sub status { 400 }
sub message { 'Bad Request' }

1;
