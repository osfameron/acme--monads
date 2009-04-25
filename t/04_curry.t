#!/usr/bin/perl
use strict; use warnings;

use Data::Dumper;

use Test::More tests => 9;
use Test::Exception;

use Monad;
use Monad::Curry;

# This API for declaring number of arguments is sucky!
# ... and also doesn't work
my $add = mdo (2) {
    mbind $x = Curry shift;
    mbind $y = Curry shift;
    return $x+$y; # not munit... which makes this strictly speaking not monadic
    };

my $triangle = mdo (3) {
    mbind $x = Curry shift;
    mbind $y = Curry shift;
    mbind $z = Curry shift;
    return $x+$y+$z;
    };

ADD: {
    isa_ok($add, 'CODE');

    is ($add->(1)->(2), 3, 'Sorta-monadic curried addition');
    is ($add->(1, 2),   3, '2 args at once');
    throws_ok { $add->(1,2,3) } qr/Expected 2 args but got 3/;
}

# We alternate here to test that the hacks to keep Monad::Proto are cleanish
TRIANGLE: {
    is ($triangle->(1,2,3),    6, 'Triangle');
    is ($triangle->(1,2)->(3), 6, 'Triangle');
    is ($triangle->(1)->(2,3), 6, 'Triangle');
    throws_ok { $triangle->(1,2)->(3,4) } qr/Expected 1 args but got 2/;
}

ADD2: {
    # back to make sure local $Curry::Args thing is sane
    my $add2 = $add->(2);
    is_deeply( [map $add2->($_), (1..3)], [3..5], 'partially applied add2 worked' );
}

