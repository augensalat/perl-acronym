use warnings;
use strict;
use lib 't/lib';

use Scalar::Util 'blessed';
use Test::Fatal;
use Test::More;

subtest failures => sub {
    require_ok 'acronym';

    like exception { acronym->import }, qr/^acronym: no acronym given at .+ line \d+\b/,
         'fails w/o acronym';
    like exception { acronym->import('x') },
         qr/^acronym: Either "alias" or "prefix" is required with 'use acronym' at .+ line \d+\b/,
         'fails w/o package alias or prefix';
    like exception { acronym->import('x', autoload => 1) },
         qr/^acronym: Either "alias" or "prefix" is required with 'use acronym' at .+ line \d+\b/,
         'fails w/o package alias or prefix';
};

subtest alias => sub {
    ok !__PACKAGE__->can('foo'), 'not has an acronym';
    ok !exception { acronym->import('foo', alias => 'Foo::Bar::Baz') },
       'create acronym';
    ok __PACKAGE__->can('foo'), 'has an acronym';
    is foo(), 'Foo::Bar::Baz', 'right result from acronym';
};

subtest prefix => sub {
    ok !__PACKAGE__->can('bar'), 'not has an acronym';
    ok !exception { acronym->import('bar', prefix => 'Bar::Baz::Qux') },
       'create acronym';
    ok __PACKAGE__->can('bar'), 'has an acronym';
    is bar('Corge::Grault'), 'Bar::Baz::Qux::Corge::Grault', 'right result from acronym with argument';
};

subtest 'alias with autoload' => sub {
    ok !__PACKAGE__->can('one'), 'not has an acronym';
    like exception { acronym->import('one', alias => 'Class::Uno', autoload => 1) },
        qr/Can't locate Class\/Uno.pm in \@INC/,
       'create acronym fails';
    ok !exception { acronym->import('one', alias => 'Class::One', autoload => 1) },
       'create acronym';
    ok __PACKAGE__->can('one'), 'has an acronym';
    ok one()->can('hello'), 'acronym class is loaded';
    ok !exception { one()->hello('world') }, 'acronym class methods are available';
    is one()->hello('world'), 'Hello, world', 'acronym class method is functional';
    ok !exception { acronym->import('one', alias => 'Class::One', autoload => 1) },
       're-create acronym does not fail';
    is one()->hello, 'Hello, Class::One', 'acronym class method is still functional';
};

subtest 'alias with instantiate' => sub {
    ok !__PACKAGE__->can('two'), 'not has an acronym';
    ok !exception { acronym->import('two', alias => 'Class::Two', instantiate => 1) },
       'create acronym';
    ok __PACKAGE__->can('two'), 'has an acronym';
    ok two()->can('new'), 'acronym class is loaded';
    my $two;
    ok !exception { $two = two(name => 'Peter') }, 'acronym auto-instantiates';
    isa_ok $two, 'Class::Two';
    is $two->get('name'), 'Peter', 'right object initialization';
};

subtest 'prefix with autoload' => sub {
    ok !__PACKAGE__->can('eins'), 'not has an acronym';
    ok !exception { acronym->import('eins', prefix => 'Class::One', autoload => 1) },
       'create acronym';
    ok __PACKAGE__->can('eins'), 'has an acronym';
    is eins(), 'Class::One', 'right class name from acronym';
    ok eins()->can('hello'), 'acronym base class is loaded';
    is eins('One'), 'Class::One::One', 'right class name from parametrized acronym';
    ok eins('One')->can('hello'), 'acronym sub class is loaded';
    ok eins('One')->can('hello2'), 'acronym sub class is loaded';
};

subtest 'prefix with instantiate' => sub {
    ok !__PACKAGE__->can('zwei'), 'not has an acronym';
    ok !exception { acronym->import('zwei', prefix => 'Class::Two', instantiate => 1) },
       'create acronym';
    ok __PACKAGE__->can('zwei'), 'has an acronym';
    ok zwei()->can('new'), 'acronym class is loaded';
    is blessed(zwei()), 'Class::Two', 'acronym returns right object instance';
    my $zwei1 = zwei(One => name => 'Paul');
    is blessed($zwei1), 'Class::Two::One', 'acronym returns right object instance';
    is $zwei1->get('name'), 'Paul', 'right object initialization';
};

subtest 'prefix with distinct constructor' => sub {
    ok !__PACKAGE__->can('x'), 'not has an acronym';
    ok !exception { acronym->import('x', prefix => 'Exception::HTTP', instantiate => 1) },
       'create acronym';
    ok __PACKAGE__->can('x'), 'has an acronym';
    ok x()->can('new'), 'acronym class is loaded';
    is blessed(x()), 'Exception::HTTP', 'acronym returns right object instance';
    my $badrequest;

    ok !exception { $badrequest = x('BadRequest') }, 'instantiate sub class';
    ok !exception { $badrequest = x('BadRequest') }, 'instantiate sub class again';
    is blessed($badrequest), 'Exception::HTTP::BadRequest', 'acronym returns right object instance';
    is $badrequest->status, 400, 'right object method result';
    ok !exception { acronym->import('z', prefix => 'Exception::HTTP', instantiate => 'foo') },
       'create acronym';
    ok __PACKAGE__->can('z'), 'has an acronym';
    like exception { z('UHM') }, qr/Can't locate Exception\/HTTP\/UHM.pm in \@INC/, 'constructor fails';
};

done_testing;
