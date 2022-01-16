package Class::One;

sub hello {
    my ($class, $who) = @_;

    return 'Hello, ' . ($who || $class);
}

1;
