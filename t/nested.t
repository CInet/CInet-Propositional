use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

propositional Semigraphoids = cube (ijk|L) ->
    (ij|L) & (ik|jL) => (ik|L) & (ij|kL);

propositional Graphoids = cube(ijk|L) ->
    Semigraphoids,
    (ij|kL) & (ik|jL) => (ij|L) & (ik|L);

propositional UndirectedGraphs = cube(ijk|L) ->
    Graphoids,
    (ij|L) => (ij|kL),
    (ij|L) => (ik|L) | (jk|L);

is 0+ UndirectedGraphs(6)->count, 32768, 'nested definitions are efficient';

done_testing;
