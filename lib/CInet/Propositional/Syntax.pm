=encoding utf8

=head1 NAME

CInet::Propositional::Syntax - Beautiful propositionals

=head1 SYNOPSIS

    # Define a CInet::Propositional::Type object via axioms
    propositional Semigraphoids = cube(ijk|L) →
        (ij|L) ∧ (ik|jL) ⇒ (ik|L) ∧ (ij|kL);

    # Unicode is optional
    propositional Gaussoids = cube(ijk|L) ::
        (ij|L)  & (ik|jL) => (ik|L)  & (ij|kL),
        (ij|kL) & (ik|jL) => (ij|L)  & (ik|L),
        (ij|L)  & (ik|L)  => (ij|kL) & (ik|jL),
        (ij|L)  & (ij|kL) => (ik|L)  | (jk|L);

    # Can also refine an existing type
    propositional Markovians = cube(ijk|L) →
        Gaussoids, (ij|L) ⇒ (ij|kL);

=cut

# ABSTRACT: Beautiful propositionals
package CInet::Propositional::Syntax;

use utf8;
use Modern::Perl 2018;
use Keyword::Declare;

=head1 DESCRIPTION

This module implements keywords via L<Keyword::Declare> that allow to
define L<CInet::Propositional::Type> objects efficiently and beautifully.

A propositional is a callable object which represents a type of CI relations
indexed by L<CInet::Cube> instances and defined via axioms.

=over

=item *

The declaration starts with the C<propositional> keyword, followed by an
identifier. This identifier will be inserted into the surrounding lexical
scope as a L<CInet::Propositional::Type> object.

=item *

Then a declaration of a C<cube(ijk...|Z)> is made. This essentially
fixes the dimension C<k> in a forbidden minor characterization of the
family using C<k> minors. The C<ijk...> part lists the names of singleton
variables and C<Z> is an arbitrary subset not containing any of those
singletons.

=item *

Then follow the clauses of a CNF describing the CI relations admitted
into the family. The syntax is close to the mathematical notation for
CI inference formulas. The singleton variables declared in the C<cube>
statement can be used on the left and right side of a CI statement,
e.g., C<(ij|Z)> and C<(ij|kZ)> are both valid. The conditioning set
C<Z> must always appear on the right side. Unicode for logical
connectives is supported.

=item *

Instead of CNF formulas, other L<CInet::Propositional::Type> objects
may be listed which results in their axioms being included.

=back

=cut

# Turn a CIStmt object into an invocation of $cube->pack.
#
# $cube is the CInet::Cube domain which exists in the lexical scope
# of the generated source code below. All the variables used by the
# CIStmt must exist as lexical variables, too.
sub pack_stmt {
    my $st = shift;
    '$cube->pack(['.
        '['. join(', ', map {  '$'.$_ } split //, $st->{ij}) .'],'.
        '['. join(', ', map({  '$'.$_ } split //, $st->{V}),
                        map({ '@$'.$_ } split //, $st->{K})) .']'.
    '])'
}

# Turn an (@ante, @cons) pair into a number of arrayrefs which represent
# clauses in the CNF of C<< @ante ⇒ @cons >>. The entries of each arrayref
# are $cube->pack invocations as per pack_stmt.
sub ci_imply {
    my ($ante, $cons) = @_;
    # Negate antecedents to model implication as a clause.
    my @ante = map { '-'.pack_stmt($_) } @$ante;
    my @clauses = [@ante];
    for my $st (@$cons) {
        push @{$clauses[-1]}, pack_stmt($st);
        # Conjunction: make a new clause for the next statement.
        push @clauses, [@ante] if $st->{':sep'} =~ m/[&∧]/;
    }
    join ",\n", map { '['. join(",\n", @$_) .']' } @clauses
}

sub import {

    keytype FaceArg is /\( (?<I>  [a-z]*)     \| (?<K> [A-Z]+) \)/x;
    keytype CIStmt  is /\( (?<ij> [a-z][a-z]) \| (?<V> [a-z]*)(?<K> [A-Z]*) \)/x;

    keyword propositional (
            Identifier $v, Attributes? $attr, '=', 'cube',
            FaceArg $arg, /→ | -> | ::/x
    ) :then(/[^,;]+/+ @stmts :sep(Comma), ';') {{{
        sub <{$v}> <{$attr}> {
            use feature qw(current_sub);
            use Algorithm::Combinatorics qw(permutations);
            use List::MoreUtils qw(part);
            use CInet::Base;
            use CInet::Propositional::Type;
            use CInet::Seq::Propositional;

            return CInet::Propositional::Type->new(__SUB__) if not @_;

            my $cube = Cube(@_);
            my $k = <{ length($arg->{I}) }>;
            my $m = <{ length($arg->{K}) }>;
            my @An = $cube->squares;
            my @Fn = $cube->faces($k);
            my @axioms;
            my %include;
            # Evaluate the axioms after '::' for every orientation of
            # every face of the requested dimension.
            #
            # For each oriented face, set local variables for the axes
            # and translation parts. They have the same names as declared
            # in $args. The CI statements used in the axioms can recombine
            # these local variables to form new CI statements.
            for my $F (@Fn) {
                my ($I, $L) = @$F;

                # An m-ary counter with L digits implements partitions of an
                # L-element set into exactly m (possibly empty!) blocks, by
                # the inverse image of the index -> digit mapping.
                my @LL;
                my @C = map { 0 } @$L;
                while (1) {
                    push @LL, [ map { [ defined($_) ? $L->@[@$_] : () ] } part { $C[$_] } 0 .. $#C ];
                    my $i = 0;
                    while ($i < @$L) {
                        if (++$C[$i] >= $m) {
                            $C[$i++] = 0;
                        }
                        else {
                            last;
                        }
                    }
                    last if $i == @$L;
                }

                for my $J (permutations($I)) {
                    # Set local variables using names specified by $arg.
                    my ( <{ join(', ', map { '$'.$_ } split //, $arg->{I}) }> ) = @$J;
                    # Loop over all decompositions of $L
                    for (@LL) {
                        my ( <{ join(', ', map { '$'.$_ } split //, $arg->{K}) }> ) = @$_;
                        <{ join ' ', map { '$'.$_ . ' //= [];' } split //, $arg->{K} }>
                        # Parse all the axioms with a separate keyword using
                        # the now-defined local variables.
                        <{ map { "_cube_push $_;\n" } @stmts }>
                    }
                }
            }
            # Push axioms of all included propositionals.
            for (values %include) {
                push @axioms, $_->($cube)->axioms->@*;
            }
            CInet::Seq::Propositional->new($cube => \@axioms)
        }
    }}}

    # Parse a single inference axiom and push it onto the outer @axioms array.
    keyword _cube_push (
            # TODO: Capturing the whitespace in :sep seems needed to get
            # the :sep key in the objects returned by Keyword::Declare.
            # Report this as a bug or feature request? This is also not
            # covered by the test suite.
            CIStmt* @ante :sep(/\s*[&∧]\s*/), /⇒ | =>/x?,
            CIStmt+ @cons :sep(/\s*[&∧|∨]\s*/)
    ) {{{
        push @axioms, <{ ci_imply \@ante => \@cons }>
    }}}

    # Remember to include another propositional's axioms in the outer
    # @axioms array. Since we can just call <{ $p }>->($cube) once to
    # get all its axioms, we should not do this in the nested loops in
    # which _cube_push is called.
    keyword _cube_push (Identifier $p) {{{
        $include{"<{ $p }>"} = <{ $p }>;
    }}}

}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
