=encoding utf8

=head1 NAME

CInet::Propositional::Type - Type object for CInet::Seq::Propositional

=head1 SYNOPSIS

    # Define a propositional type object.
    propositional Semigraphoids = cube (ijk|L) -> (ij|L) & (ik|jL) => (ij|kL) & (ik|L);

    # Get a CInet::Seq::Propositional for its elements on a 4-element ground set:
    my $seq = Semigraphoids(4);

=head1 DESCRIPTION

This class exists for syntax beauty reasons. It is a blessed C<sub> created
by the C<propositional> keyword which when called with a C<Cube>-like argument
produces a L<CInet::Seq::Propositional>.

=cut

# ABSTRACT: Type object for CInet::Seq::Propositional
package CInet::Propositional::Type;

sub new {
    my ($class, $sub) = @_;
    bless $sub, $class
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
