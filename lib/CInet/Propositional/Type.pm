=encoding utf8

=head1 NAME

CInet::Propositional::Type - Type object for CInet::Seq::Propositional

=head1 SYNOPSIS

    ...

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
