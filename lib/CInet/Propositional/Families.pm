=encoding utf8

=head1 NAME

CInet::Propositional::Families - Predefined families of CI relations

=head1 SYNOPSIS

    use CInet::Propositional::Families;
    say Semigraphoids(4)->count;

=head1 DESCRIPTION

This module defines commonly used `propositional` types:

=over

=item *

Semigraphoids

=item *

Graphoids

=item *

Semigaussoids (or compositional graphoids)

=item *

Gaussoids

=item *

MarkovNetworks (or undirected graphical models)

=back

=cut

# ABSTRACT: Predefined families of CI relations
package CInet::Propositional::Families;

use utf8;
use Modern::Perl 2018;
use Export::Attrs;

use CInet::Propositional::Syntax;

propositional Semigraphoids :Export(:DEFAULT) = cube(ijk|L) ->
    (ij|L) & (ik|jL) => (ij|kL) & (ik|L);

propositional Graphoids :Export(:DEFAULT) = cube(ijk|L) ->
    (ij|L) & (ik|jL) => (ij|kL) & (ik|L),
    (ij|kL) & (ik|jL) => (ij|L) & (ik|L);

propositional Semigaussoids :Export(:DEFAULT) = cube(ijk|L) ->
    (ij|L) & (ik|jL) => (ij|kL) & (ik|L),
    (ij|kL) & (ik|jL) => (ij|L) & (ik|L),
    (ij|L) & (ik|L) => (ij|kL) & (ik|jL);

propositional Gaussoids :Export(:DEFAULT) = cube(ijk|L) ->
    (ij|L) & (ik|jL) => (ij|kL) & (ik|L),
    (ij|kL) & (ik|jL) => (ij|L) & (ik|L),
    (ij|L) & (ik|L) => (ij|kL) & (ik|jL),
    (ij|L) & (ij|kL) => (ik|L) | (jk|L);

propositional MarkovNetworks :Export(:DEFAULT) = cube(ijk|L) ->
    (ij|L) & (ik|jL) => (ij|kL) & (ik|L),
    (ij|kL) & (ik|jL) => (ij|L) & (ik|L),
    (ij|L) => (ij|kL),
    (ij|L) => (ik|L) | (jk|L);

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2024 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
