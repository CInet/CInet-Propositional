use utf8;
use Modern::Perl 2018;

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

# Can also refine an existing type
propositional Markovians = cube(ijk|L) →
    Gaussoids, (ij|L) ⇒ (ij|kL);

is Semigraphoids(3)->count, 22, 'count of 3-semigraphoids';
is Semigraphoids(3)->modulo(SymmetricGroup)->count, 10, 'count of isomorphy classes of 3-semigraphoids';
is Semigraphoids(4)->count, 26424, 'count of 4-semigraphoids';
is Semigraphoids(4)->modulo(SymmetricGroup)->count, 1512, 'count of isomorphy classes of 4-semigraphoids';
is Gaussoids(3)->count, 11, 'count of 3-gaussoids';
is Gaussoids(4)->count, 679, 'count of 4-gaussoids';
is Markovians(4)->count, 64, 'count of 4-markov networks';

done_testing;
