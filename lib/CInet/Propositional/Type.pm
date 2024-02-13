=encoding utf8

=head1 NAME

CInet::Propositional::Type - Type object for CInet::Seq::Propositional

=head1 SYNOPSIS

    # Define a propositional type object Semigraphoids.
    propositional Semigraphoids = cube (ijk|L) -> (ij|L) & (ik|jL) => (ij|kL) & (ik|L);

    # Get a CInet::Seq::Propositional for its elements on a 4-element ground set:
    my $seq = Semigraphoids(4);

=head1 DESCRIPTION

This class exists for syntax beauty reasons. It is a blessed C<sub> created
by the C<propositional> keyword which when called with a C<Cube>-like argument
produces a L<CInet::Seq::Propositional>.

An object of this class represents an entire concept of CI structures, like
"semigraphoids" or "gaussoids". In the future it will be possible to pass
these concepts to blackbox algorithms (such as closure computations,
seladhesivity testing or axiom derivation).

=cut

# ABSTRACT: Type object for CInet::Seq::Propositional
package CInet::Propositional::Type;

use CInet::Base;

# TODO: We should maybe cache formulas.

=head2 Methods

=cut

sub new {
    my ($class, $sub) = @_;
    bless $sub, $class
}

=head3 test

    my $bool = $type->test($A);

Test if a relation C<$A> satisfies the axioms of C<$type>.

=cut

sub test {
    my ($self, $A) = @_;
    $self->(Cube($A))->contains($A)
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
