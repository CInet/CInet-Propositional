use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

sub rel { CInet::Relation->new(3 => shift) }

ok  Semigraphoids->test(rel '010101'), 'semigraphoid testing 1';
ok !Semigraphoids->test(rel '000111'), 'semigraphoid testing 2';

done_testing;
