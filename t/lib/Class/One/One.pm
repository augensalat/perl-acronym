package Class::One::One;

use base 'Class::One';

sub hello2 {
    my ($class, $who) = @_;

    return 'Hello hello, ' . ($who || $class);
}

1;
