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
            Identifier $v, '=', 'cube',
            FaceArg $arg, /→ | -> | ::/x
    ) :then(/[^,;]+/+ @stmts :sep(Comma), ';') {{{
        sub <{$v}> {
            use Algorithm::Combinatorics qw(permutations);
            use List::MoreUtils qw(part);

            return CInet::Propositional::Type->new(__SUB__) if not @_;

            my $cube = Cube(@_);
            my $k = <{ length($arg->{I}) }>;
            my $m = <{ length($arg->{K}) }>;
            my @An = $cube->squares;
            my @Fn = $cube->faces($k);
            my @axioms;
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

    # Include another propositional's axioms in the outer @axioms array.
    keyword _cube_push (Identifier $p) {{{
        push @axioms, <{ $p }> ->($cube)->axioms->@*
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
