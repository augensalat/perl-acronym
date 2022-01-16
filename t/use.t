use warnings;
use strict;
use lib 't/lib';

use Scalar::Util 'blessed';
use Test::Fatal;
use Test::More;

BEGIN {
    use_ok 'acronym', 'foo', alias  => 'Foo::Bar::Baz';
    use_ok 'acronym', 'bar', prefix => 'Bar::Baz::Qux';
    use_ok 'acronym', 'one', alias  => 'Class::One', autoload    => 1;
    use_ok 'acronym', 'two', alias  => 'Class::Two', instantiate => 1;
    use_ok 'acronym', 'uno', prefix => 'Class::One', autoload    => 1;
    use_ok 'acronym', 'due', prefix => 'Class::Two', instantiate => 1;
    use_ok 'acronym', 'X', prefix => 'Exception::HTTP', instantiate => 'throw';
}

subtest failures => sub {
    eval 'use acronym';
    like $@, qr/^acronym: no acronym given at .+ line \d+\b/, 'fails w/o acronym';

    eval "use acronym 'x'";
    like $@, qr/^acronym: Either "alias" or "prefix" is required with 'use acronym' at .+ line \d+\b/,
         'fails w/o package alias or prefix';

    eval "use acronym 'x', autoload => 1";
    like $@, qr/^acronym: Either "alias" or "prefix" is required with 'use acronym' at .+ line \d+\b/,
         'fails w/o package alias or prefix';

    eval <<'USE';
package main;
#line 42 caller.pl
use acronym 'x', alias => 'Module::That::Hopefully::Doesnt::Exist', autoload => 1;
1;
USE
    like $@, qr/
        \ACan't \s+ locate \s+ Module\/That\/Hopefully\/Doesnt\/Exist\.pm \s+ in \s+ \@INC        .+
        at \s+ caller\.pl \s+ line \s+ 42\b
    /mx,
        'fails w/ not existing package w/ right filename and line numer';
};

subtest alias => sub {
    ok __PACKAGE__->can('foo'), 'has an alias acronym';
    is foo, 'Foo::Bar::Baz', 'right result from acronym';
    eval "foo('bar')";
    like $@, qr/^Too many arguments for main::foo at .+ line \d+\b/,
        'alias acronym fails w/ one argument';
    eval "foo(bar => 'baz')";
    like $@, qr/^Too many arguments for main::foo at .+ line \d+\b/,
        'alias acronym fails w/ many arguments';
};

subtest prefix => sub {
    ok __PACKAGE__->can('bar'), 'has an acronym';
    is bar('Corge::Grault'), 'Bar::Baz::Qux::Corge::Grault', 'right result from acronym with argument';
};

subtest 'alias with autoload' => sub {
    ok __PACKAGE__->can('one'), 'has an acronym';
    ok one->can('hello'), 'acronym class is loaded';
    ok !exception { one->hello('world') }, 'acronym class methods are available';
    is one->hello('world'), 'Hello, world', 'acronym class method is functional';
    eval "one('SubClass')";
    like $@, qr/^Too many arguments for main::one at .+ line \d+\b/,
        'autoloaded alias acronym fails w/ one argument';
    eval "one(foo => 'bar')";
    like $@, qr/^Too many arguments for main::one at .+ line \d+\b/,
        'autoloaded alias acronym fails w/ many arguments';
};

subtest 'alias with instantiate' => sub {
    my $two;

    ok __PACKAGE__->can('two'), 'has an acronym';
    ok !exception { two }, 'acronym called w/o arguments';
    is blessed(two), 'Class::Two', 'acronym w/o arguments returns right object instance';
    ok !exception { $two = two(name => 'Peter') }, 'acronym auto-instantiates';
    is blessed($two), 'Class::Two', 'acronym returns right object instance';
    is $two->get('name'), 'Peter', 'right object initialization';
};

subtest 'prefix with autoload' => sub {
    ok __PACKAGE__->can('uno'), 'has an acronym';
    is uno, 'Class::One', 'acronym returns right class name';
    is uno('One'), 'Class::One::One', 'right class name from parametrized acronym';
    ok uno('One')->can('hello'), 'acronym sub class is loaded';
    ok uno('One')->can('hello2'), 'acronym sub class is loaded';
};

subtest 'prefix with instantiate' => sub {
    my ($due_undef, $due1);

    ok __PACKAGE__->can('due'), 'has a prefix/instantiate acronym';
    is blessed(due), 'Class::Two', 'acronym returns right object instance';

    ok !exception { $due_undef = due undef, name => 'Paul' },
        'create acronym object w/o prefix and w/ arguments';
    is blessed($due_undef), 'Class::Two', 'acronym returns right object instance';
    is $due_undef->get('name'), 'Paul', 'right object initialization';

    ok !exception { $due1 = due 'One', name => 'Mary' }, 'acronym auto-instantiates';
    is blessed($due1), 'Class::Two::One', 'acronym returns right object instance';
    is $due1->get('name'), 'Mary', 'right object initialization';
};

subtest 'prefix with explicit constructor' => sub {
    ok __PACKAGE__->can('X'), 'has a prefix/instantiate acronym';
    is exception { X('BadRequest') }, '400 Bad Request', 'right constructor';
    is exception { X('NotFound', path => '/foo/bar') }, '404 Not Found, path: /foo/bar',
        'right constructor';
};

done_testing;
