use utf8;
use Modern::Perl 2018;
use Scalar::Util qw(blessed);

use CInet::Base;
use CInet::Propositional;

use Test::More;

# Define a CInet::Propositional::Type object via axioms
propositional Semigraphoids = cube(ijk|L) →
    (ij|L) ∧ (ik|jL) ⇒ (ik|L) ∧ (ij|kL);

# Unicode is optional
propositional Gaussoids = cube(ijk|L) ::
    (ij|L)  & (ik|jL) => (ik|L)  & (ij|kL),
    (ij|kL) & (ik|jL) => (ij|L)  & (ik|L),
    (ij|L)  & (ik|L)  => (ij|kL) & (ik|jL),
    (ij|L)  & (ij|kL) => (ik|L)  | (jk|L);

is blessed(Gaussoids(4)->solver), 'CInet::ManySAT', 'solver is CInet::ManySAT';
is Gaussoids(4)->solver->count, 679, 'count works';

done_testing;
