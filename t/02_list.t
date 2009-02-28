#!/usr/bin/perl

use Data::Dumper;

use Test::More tests => 2;

use Monad;
use Monad::List;

my $list = mdo {
    mbind $x = List (1..2);
    mbind $y = List (3..4);
    munit [$x, $y]
    };

is_deeply( $list, 
            bless( [
                    [ 1, 3 ],
                    [ 1, 4 ],
                    [ 2, 3 ],
                    [ 2, 4 ]
                  ], 'Monad::List' ), 'List is ok' );

my $list2 = mdo {
    mbind $x = List (1..10);
    mbind $y = List (1..10);
    mbind guard $x + $y == 10;
    munit [$x, $y]
    };

is_deeply( $list2, 
            bless( [
                    [ 1, 9 ],
                    [ 2, 8 ],
                    [ 3, 7 ],
                    [ 4, 6 ],
                    [ 5, 5 ],
                    [ 6, 4 ],
                    [ 7, 3 ],
                    [ 8, 2 ],
                    [ 9, 1 ],
                  ], 'Monad::List' ), 'List is ok' );
