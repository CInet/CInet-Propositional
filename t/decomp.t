use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

propositional Semigraphoids = cube(ijk|L) →
    (ij|L) ∧ (ik|jL) ⇒ (ij|kL) ∧ (ik|L);

propositional Somethings = cube(ijl|KL) →
    Semigraphoids,
    (ij|K) | (il|jKL);

is Somethings(3)->modulo(SymmetricGroup)->count,  4, 'somethings on 3 elements';
is Somethings(4)->modulo(SymmetricGroup)->count,  9, 'somethings on 4 elements';
is Somethings(5)->modulo(SymmetricGroup)->count, 21, 'somethings on 5 elements';

done_testing;
