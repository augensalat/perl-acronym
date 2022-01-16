package Exception::HTTP::NotFound;

use base 'Exception::HTTP';

sub status { 404 }
sub message { 'Not Found' }

sub stringify {
    my $s = $_[0]->status . ' ' . $_[0]->message;

    $s .= ", path: $_[0]->{path}" if defined $_[0]->{path};

    return $s;
};

1;
