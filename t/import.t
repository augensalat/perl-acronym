use warnings;
use strict;

use Test::Fatal;
use Test::More;

require_ok 'acronym';

like exception { acronym->import }, qr/^acronym: no acronym given at .+ line \d+\./,
     'fails w/o acronym';
like exception { acronym->import('x') },
     qr/^acronym: no package initial given at .+ line \d+\./,
     'fails w/o package initial';

ok !__PACKAGE__->can('foo'), 'not has an acronym';

ok !exception { acronym->import('foo', 'Foo::Bar::Baz') },
   'create acronym';

ok __PACKAGE__->can('foo'), 'has an acronym';

is foo(), 'Foo::Bar::Baz', 'right result from acronym';
is foo('Qux'), 'Foo::Bar::Baz::Qux', 'right result from acronym with argument';

ok foo("BAR", "BAZ");

done_testing;
