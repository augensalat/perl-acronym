package Exception::HTTP;

use Carp 'croak';
use overload
    '""'     => 'stringify',
    '0+'     => sub { $_[0]->status },
    fallback => 1;

sub new {
    my $class = shift;

    croak "odd number of elements in named argument list" if @_ % 2;

    return bless {@_, status => $class->status, message => $class->message}, $class;
}

sub throw {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    die $class->new(@_);
}

sub status { 0 }
sub message { "" }

sub stringify { $_[0]->status . ' ' . $_[0]->message };
1;
