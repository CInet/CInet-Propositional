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

use Modern::Perl 2018;
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
    defined $self->(Cube($A))->consistent($A)
}

=head3 imply

    my $bool = $type->imply($A => @C);

Check if the assumptions in the relation C<$A> together with the axioms
of C<$type> imply the validity of the I<disjunction> of CI statements in
C<@C>.

Note that independences I<and> dependences in C<$A> contribute to the
assumptions! If for example C<$A> contains a dependence which implied
as an independence by other independences of C<$A>, then the assumptions
are contradictory and every conclusion is implied. If you only want to
assume the independences in C<$A>, use L<weakly_imply|/"weakly_imply>.

=cut

sub imply {
    my ($self, $A, @C) = @_;
    my $B = $A->clone;
    for (@C) {
        return 1 if $B->cival($_) eq 0; # trivial
        $B->cival($_) = 1;
    }
    not $self->test($B)
}

=head3 weakly_imply

    my $bool = $type->weakly_imply($L => @C);

Check if the independence assumptions in the relation C<$L> together with
the axioms of C<$type> imply the validity of the I<disjunction> of CI
statements in C<@C>.

=cut

sub weakly_imply {
    my ($self, $A, @C) = @_;
    my $B = CInet::Relation->new(Cube($A));
    $B->cival($_) = 0 for $A->independences;
    for (@C) {
        return 1 if $B->cival($_) eq 0; # trivial
        $B->cival($_) = 1;
    }
    not $self->test($B)
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
