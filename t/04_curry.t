#!/usr/bin/perl
use strict; use warnings;

use Data::Dumper;

use Test::More tests => 3;

use Monad;
use Monad::Curry;

my $add = mdo {
    mbind $x = Curry shift;
    mbind $y = Curry shift;
    return $x+$y; # not munit... which makes this strictly speaking not monadic
    };

isa_ok($add, 'CODE');

is ($add->(1)->(2), 3, 'Sorta-monadic curried addition');

my $add2 = $add->(2);

is_deeply( [map $add2->($_), (1..3)], [3..5], 'partially applied add2 worked' );

