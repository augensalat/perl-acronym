package acronym;

use strict;
use warnings;

use Carp ();
use Sub::Util ();

our $VERSION = '0.1.0';

sub import {
    my ($class, $caller) = (shift, caller);
    my $acronym = shift
        or Carp::croak "$class: no acronym given";
    my $base = shift
        or Carp::croak "$class: no package initial given";

    no strict 'refs';
    no warnings 'redefine';

    *{"${caller}::$acronym"} = Sub::Util::set_subname "${caller}::$acronym",
        sub {
            return $base . '::' . $_[0] if @_;
            return $base;
        };

    return;
}

1; # End of acronym

__END__

=head1 NAME

acronym - Unobtrusive Tiny Package Name Amputator

=head1 VERSION

Version 0.1.0

=head1 SYNOPSIS

  package BigCompany::MyDepartment::ProjectX::WebService::Controller::MacGuffin;

  use namespace::autoclean;

  use acronym Error => 'BigCompany::MyDepartment::ProjectX::WebService::Error::HTTP';

  ...

  die Error('NotFound')->new(message => 'Data not found');

=head1 DESCRIPTION

If you hate writing code like

  die BigCompany::MyDepartment::ProjectX::WebService::Error::HTTP::NotFound->new(
    message => 'Data not found'
  );

again and again, then this module might be for you.

=head1 EXPORT

Whenver used this package exports a subroutine into the caller's namespace with
the name that is given as the first argument after C<use acronym>.

=head1 SUBROUTINES

=head2 import

The C<import> sub is called by C<use acronym>.

=head1 AUTHOR

Bernhard Graf

=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/augensalat/perl-acronym/issues>.

=head1 ACKNOWLEDGEMENTS

Similar modules have existed on CPAN for quite some time which inspired me to
write yet another one.

=head2 aliased

=head2 as

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Bernhard Graf.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
