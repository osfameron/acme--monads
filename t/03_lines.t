#!/usr/bin/perl

use Data::Dumper;

use Test::More tests => 4;
use Test::Exception;

use Monad;
use Monad::Maybe;

my $expected = bless \do {my $x=3}, 'Monad::Just';

SINGLE: {
    my $ret = mdo {
        mbind $x = Just 1 + 2;
        munit $x;
        };
    is_deeply( $ret, $expected, "Single line check" );
}

MULTI: {
    local $TODO = "Multiline parsing";

    my $ret = mdo {
        mbind $x = Just 1
            + 2;
        munit $x;
        };
    is_deeply( $ret, $expected, "Multiple line check" );
}

EVALY: {
    # check that we can be called in an eval

    local $TODO = "Eval fail!";
    
    my $ret = eval q[
        mdo {
           mbind $x = Just 1; 
           mbind $y = Just 2;
           munit $x + $y;
           };
        ];
    if ($@) {
        fail "Error $@";
    } else {
        is_deeply( $ret, $expected, "Sanity check for next (partial line) test" );
    }
}

__DATA__
PARTIAL: {
    local $TODO = "Partial line parsing";

    my $ret;
    lives_ok {
        eval q{
            $ret = mdo {
                mbind $x = Just 1; mbind $y = Just 2;
                munit $x + $y;
                };
            };
        } 'Partial line compiled';
    is_deeply( $ret, $expected, "Partial line check" );
}
