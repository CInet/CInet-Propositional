use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

sub rel { CInet::Relation->new(@_) }

ok  Semigraphoids->imply(rel(3, '0**0**') => [[1,2],[3]]), 'semigraphoid derivation';
ok  Gaussoids->imply(rel(3, '00****') => [[1,3],[]], [[2,3],[]]), 'disjunction implication 1';
ok !Gaussoids->imply(rel(3, '00****') => [[1,3],[]]), 'disjunction implication 2';
ok !Gaussoids->imply(rel(3, '00****') => [[2,3],[]]), 'disjunction implication 3';
ok  Gaussoids->imply(rel(3, '001***') => [[2,3],[]]), 'disjunction implication 4';

done_testing;
