package acronym;

use strict;
use warnings;

use Carp 'croak';
use Sub::Util qw(set_prototype set_subname);

our $VERSION = '0.1.0';

my %Loaded;

sub import {
    my $me = shift;
    my $acronym = shift or croak "$me: no acronym given";
    my %args = @_;
    my $alias  = $args{alias};
    my $prefix = $args{prefix};

    !$alias ^ !$prefix or croak qq($me: Either "alias" or "prefix" is required with 'use acronym');

    my $caller = caller;
    my $constructor = $args{instantiate} ?
        $args{instantiate} =~ /^[A-Za-z_]\w+$/ ? $args{instantiate} : 'new' :
        undef;
    my $autoload = exists($args{autoload}) ? $args{autoload} : !!$args{instantiate};
    # my $prototype = $constructor ? '@' : $prefix ? '$' : '';
    my $prototype = $constructor ? '@' : $prefix ? ';$' : '';

    # for alias mode auto-loading can happen in compile phase
    _load_class($alias, $constructor) if $autoload and $alias;

    no strict 'refs';
    no warnings 'redefine';

    *{"${caller}::$acronym"} =
        set_subname "${caller}::$acronym",
        set_prototype $prototype,
            sub {
                my $class;

                if ($prefix) {
                    my $tail = shift;
                    $class = $prefix . ($tail ? '::' . $tail : '');
                }
                else {
                    $class = $alias;
                }

                _load_class($class, $constructor) if $autoload and $prefix;

                return $constructor ? $class->$constructor(@_) : $class;
            };

    return;
}

sub _load_class {
    my ($class, $constructor) = @_;

    if ($constructor) {
        $class->can($constructor) or _require_or_die($class);
    }
    elsif (not $Loaded{$class}) {
        $Loaded{$class} = _require_or_die($class);
    }
}

sub _require_or_die {
    my ($class) = @_;

    return eval "require $class; 1"
        || $@ =~ /\A(.+) \s+ at \s+ \(eval \s+ \d+\) \s+ line \s+ 1 \. \Z/mx
        && croak $1
        || die $@;
}

1; # End of acronym

__END__

=head1 NAME

acronym - DWIM Package Aliases

=head1 VERSION

Version 0.1.0

=head1 SYNOPSIS

  package BigCompany::MyDepartment::ProjectX::WebService::Controller::MacGuffin;

  use namespace::autoclean; # eventually remove acronyms from namespace

  use acronym 'Log',
    alias => 'BigCompany::MyDepartment::ProjectX::WebService::Logger',
    autoload => 1;
  use acronym 'Model',
    prefix => 'BigCompany::MyDepartment::ProjectX::WebService::Model',
    instantiate => 1;
  use acronym 'throw',
    prefix => 'BigCompany::MyDepartment::ProjectX::WebService::Error::HTTP'
    instantiate => 'throw';

  ...
  Log->debug("find MacGuffin #$id");
  Model('MacGuffin', connect => $config->{dsn})->find($id)
    or throw 'NotFound', message => 'Data not found';

=head1 DESCRIPTION

If you hate writing code like

  die BigCompany::MyDepartment::ProjectX::WebService::Error::HTTP::NotFound->new(
    message => 'Data not found'
  );

again and again, then this module might be for you.

C<acronym> generates and exports a subroutine - the I<acronym function> - into
your namespace whose name must be specified as the first argument of the
C<use acronym> statement. In the simplest form the acronym function returns an
alias for a (longer) package name.

C<acronym> can also load that package. And the subroutine can be a constructor
function - rather than returning the referenced package name every invocation
then creates an object instance of the particular class.

Finally just the front part of a package name may be defined and the C<acronym>
subroutine does specify the other part of the package name to be aliased, loaded
or instantiated. Thus a whole collection of packages or classes can be
abbreviated with one acronym function.

The various options are controlled by arguments following C<use acronym>.

The first argument defines the name of the acronym function, a subroutine which
is exported into the caller's namespace.

A list of named arguments follows and specifies how the acronym function works.
It must at least contain an L</alias> or a L</prefix> argument. These two
arguments are mutually exclusive.

=head2 alias

  use acronym 'Log', alias => 'My::App::Logger';
  use My::App::Logger;

  # My::App::Logger->info('Data is served')
  Log->info('Data is served');

The value the acronym function refers to is meant to be a package or class name.

=head2 prefix

  use acronym 'X', prefix => 'My::App::Exception';
  use My::App::Exception::Game::Over;

  # My::App::Exception::Game::Over->throw(message => '**TILT**');
  X('Game::Over')->throw(message => '**TILT**');

The C<prefix> parameter defines the common initial part of a collection of class
names. The first argument of the generated acronym function is then the
remaining part of the particular class name.

=head2 autoload

  use acronym 'Log', alias => 'My::App::Logger', autoload => 1;

  # My::App::Logger->info('Data is served');
  Log->info('Data is served');

Load the package if the C<autoload> value is true-ish. In combination with the
L</alias> argument auto-loading happens at compile-time, whereas with L</prefix>
auto-loading is performed when the acroynm subroutine is called with a
particular argument for the first time. This option is off by default.

=over

=item Note 1:

With the C<autoload> option the respective package is just C<require>'d and not
C<use>'d. That means that the C<import> subroutine of the loaded package is not
executed and things like importing subroutines are not performed. If you need
this you must C<use> the package before you create an C<acronym> for it.

=item Note 2:

For the same reason packages that create symbols in other namespaces (like
L<HTTP::Exception>) must be C<use>'d explicitly as well.

=back

=head2 instantiate

  use acronym 'Model', alias => 'My::App::Model::CSV', instantiate => 1;

  # My::App::Model::CSV->new(file => $csv_file)->find(status => 'fail');
  my @rows = Model(file => $csv_file)->find(status => 'fail');

Load the class and create an instance with C<< $class->new() >>. In the example
above C<instantiate> is combined with C<alias>, so the acronym function C<Model>
proxies all arguments to the class constructor C<My::App::Model::CSV::new>.

If the value for C<instantiate> is a true-ish number (typically C<1>) then
the class constructor is assumed to have the name C<new>. A non-numeric value
specifies the constructor name explicitly.

  use acronym 'X', prefix => 'My::App::Exception', instantiate => 'throw';

  # My::App::Exception::Game::Over->throw(message => '**TILT**');
  X 'Game::Over', message => '**TILT**';

In this example C<instantiate> is combined with C<prefix>, so the acronym
function expects the remaining part of the class name as first argument,
followed by the arguments for the class constructor.

The default value for C<instantiate> is C<0>. If enabled it implicitly sets
L</autoload> to true if that is not explicitly set to false.

=head1 EXPORT

Whenever you C<use acronym> the first argument is the name of a subroutine that
is exported into your namespace.

=head1 SUBROUTINES

=head2 import

This is called by L<use|perlfunc/use> and handles the C<acronym> arguments.

=head1 AUTHOR

Bernhard Graf

=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/augensalat/perl-acronym/issues>.

=head1 ACKNOWLEDGEMENTS

Similar modules have existed on CPAN for quite some time which inspired me to
write yet another one.

=head2 aliased

This module offers two different approaches to the same problem, depending on
how you use it. The C<prefix> function has been marked "experimental" for over
a decade now.

=head2 as

Offers a nice syntax at the expense of patching Perl's CORE "require" function.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Bernhard Graf.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
