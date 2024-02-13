use utf8;
use Modern::Perl 2018;
use Scalar::Util qw(blessed);

use CInet::Base;
use CInet::Propositional;

use Test::More;

is blessed(Gaussoids(4)->solver), 'CInet::ManySAT', 'solver is CInet::ManySAT';
is Gaussoids(4)->solver->count, 679, 'count works';

done_testing;
