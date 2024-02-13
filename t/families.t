use utf8;
use Modern::Perl 2018;

use CInet::Base;
use CInet::Propositional;

use Test::More;

# Almost the same test as simple.t but using the built-in families.
is Semigraphoids(3)->count, 22, 'count of 3-semigraphoids';
is Semigraphoids(4)->count, 26424, 'count of 4-semigraphoids';
is Graphoids(3)->count, 18, 'count of 3-graphoids';
is Graphoids(4)->count, 6482, 'count of 4-graphoids';
is Semigaussoids(3)->count, 14, 'count of 3-semigaussoids';
is Semigaussoids(4)->count, 2084, 'count of 4-semigaussoids';
is Gaussoids(3)->count, 11, 'count of 3-gaussoids';
is Gaussoids(4)->count, 679, 'count of 4-gaussoids';
is MarkovNetworks(3)->count, 8, 'count of 3-markov networks';
is MarkovNetworks(4)->count, 64, 'count of 4-markov networks';

done_testing;
