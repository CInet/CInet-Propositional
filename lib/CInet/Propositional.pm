=encoding utf8

=head1 NAME

CInet::Propositional - CI inference axioms and SAT solvers

=head1 SYNOPSIS

    # Imports all related modules
    use CInet::Propositional;

=head2 VERSION

This document describes CInet::Propositional v0.9.2.

=cut

# ABSTRACT: CI inference axioms and SAT solvers
package CInet::Propositional;

our $VERSION = "v0.9.2";

=head1 DESCRIPTION

This module imports all modules in its distribution, most notably
L<CInet::Propositional::Syntax> which defines the C<propositional>
keyword. Using this keyword, families of CI relations can be
defined axiomatically using a syntax very close to mathematics:

    propositional Semigraphoids = cube (ijk|L) -> (ij|L) & (ik|jL) => (ij|kL) & (ik|L);

This results in a L<CInet::Propositional::Type> object which can
be instantiated by giving a L<CInet::Cube> object. This results
in a L<CInet::Seq::Propositional> sequence representing all
L<CInet::Relation>s compatible with the axioms:

    say Semigraphoids(4)->count #= 26424

There are indeed 26424 semigraphoids on a 4-element ground set.
This number is obtained in the blink of an eye because the set
is defined axiomatically and by being a L<CInet::Seq::Propositional>,
a #SAT solver is used for counting.

=cut

use Modern::Perl 2018;
use Import::Into;

sub import {
    CInet::Propositional::Type     -> import::into(1);
    CInet::Seq::Propositional      -> import::into(1);
    CInet::Propositional::Syntax   -> import::into(1);
    CInet::Propositional::Families -> import::into(1);
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
