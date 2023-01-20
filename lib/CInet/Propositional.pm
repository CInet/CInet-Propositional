=encoding utf8

=head1 NAME

CInet::Propositional - CI inference axioms and SAT solvers

=head1 SYNOPSIS

    # Imports all related modules
    use CInet::Propositional;

=head2 VERSION

This document describes CInet::Propositional v0.0.1.

=cut

# ABSTRACT: CI inference axioms and SAT solvers
package CInet::Propositional;

our $VERSION = "v0.0.1";

=head1 DESCRIPTION

TODO

=cut

use Modern::Perl 2018;
use Import::Into;

sub import {
    CInet::Propositional::Type   -> import::into(1);
    CInet::Seq::Propositional    -> import::into(1);
    CInet::Propositional::Syntax -> import::into(1);
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
