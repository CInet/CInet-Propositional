=encoding utf8

=head1 NAME

CInet::Seq::Propositional - Axiomatically defined relations

=head1 SYNOPSIS

    ...

=cut

# ABSTRACT: Axiomatically defined relations
package CInet::Seq::Propositional;

use Modern::Perl 2018;
use Carp;

use CInet::ManySAT;

=head1 DESCRIPTION

This class provides the interface of L<CInet::Seq> for collections
of axiomatically defined C<CInet::Relation>s. Each instance of this
class has a backing system of axioms, which are a Boolean formula in
conjunctive normal form (CNF). Various actions on the sequence are
implemented as efficiently as possible by manipulating the axioms
and by calling into the SAT solvers from L<CInet::ManySAT>.

This class implements the L<CInet::Seq> role.

=cut

use Role::Tiny::With;
with 'CInet::Seq';

=head2 Methods

=head3 new

    my $prop = CInet::Propositional::Seq->new($cube, \@axioms, \&relify);

Constructs a CInet::Propositional::Seq object which iterates
C<CInet::Relation> objects on the given C<$cube>. The structures
contained in the sequence are encoded by the satisfying assignments
to the given C<@axioms>, given in conjunctive normal form, suitable
for passing into L<CInet::ManySAT>'s C<read> method.

By default, all objects returned from this sequence are blessed
into C<CInet::Relation> on the given cube. A true Boolean variable
maps to a true independence statement, so to a B<0> coefficient
in the relation. This assumes that the variables are numbered
C<< 1 .. $cube->squares >>.

If you have different encodings, you can specify your own C<&relify>
coderef, which receives the satisfying assignment directly from
L<CInet::ManySAT>, as an array of negated and non-negated variable
numbers. Your coderef can access the model via C<$_> or C<@_>.
The C<$cube> is passed in as a second argument.

=cut

sub new {
    my ($class, $cube, $axioms, $relify) = @_;
    $relify //= sub {
        CInet::Relation->new($cube =>
            join '', map { $_ < 0 ? '1' : '0' } $_->@*
        )
    };
    my $solver = CInet::ManySAT->new->read($axioms);
    bless { cube => $cube, solver => $solver, relify => $relify }, $class
}

=head3 axioms

    my $axioms = $prop->axioms;

Returns an arrayref of arrayrefs which represents a conjunction
of clauses. Each clause, an inner arrayref, contains positive and
negative integers, each representing a literal in the clause.

=cut

sub axioms {
    shift->{solver}->clauses
}

=head2 Implementation of CInet::Seq

=head3 inhabited

    my $model = $prop->inhabited;

Returns a model if C<$prop> is satisfiable and otherwise C<undef>.
Unlike the vanilla L<CInet::Seq#inhabited> method this has no
side effects on the available elements in C<$prop>, because a
separate SAT solver is started on the backing formula.

Accepts the same arguments as L<CInet::ManySAT#model>.

=cut

sub inhabited {
    my ($cube, $solver, $relify) = shift->@{'cube', 'solver', 'relify'};
    local $_ = $solver->model(@_);
    not(defined) ? undef : $relify->($_, $cube)
}

=head3 count

    my $count = $prop->count;

Return the number of elements in the sequence, which is the number
of satisfying assignments to the backing formula. Unlike the vanilla
L<CInet::Seq#count> method, this does not exhaust the sequence,
because a separate #SAT solver is started on the backing formula.

Accepts the same arguments as L<CInet::ManySAT#count>.

=cut

sub count {
    my $solver = shift->{solver};
    $solver->count(@_)
}

=head3 next

    my $elt = $prop->next;
    last if not defined $elt;

Pull the next satisfying assignment of the backing formula. If not
running already, an AllSAT solver is started which carries out the
enumeration. This solver runs in a separate process and fills an
IPC buffer with new models. It is automatically put to sleep when this
fixed-size buffer is full, so no extraordinary amounts of memory will
be used in case the consumer of this Seq is slow. In addition, the
enumeration is automatically canceled when this object is destroyed.

On an invocation of this method which starts the AllSAT solver,
all arguments are forwarded to L<CInet::ManySAT#all>.

=cut

sub next {
    my $self = shift;
    my ($cube, $relify, $all) = $self->@{'cube', 'relify', 'all'};

    if (not defined $all) {
        $self->{all} = $all =
            $self->{solver}->all(@_);
    }

    local $_ = $all->next;
    not(defined) ? undef : $relify->($_, $cube)
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
