package Class::Two;

sub new {
    my ($class, %attr) = @_;

    return bless \%attr, $class;
}

sub get {
    my ($self, $key) = @_;

    return $self->{$key};
}

1;

