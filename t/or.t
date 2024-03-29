use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

propositional orclause = cube(ijk|L) →
    (ij|L) | (ij|kL);

is orclause(3)->count, 27, 'or clause works';

done_testing;
