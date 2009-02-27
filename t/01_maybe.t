#!/usr/bin/perl

use Data::Dumper;

use Test::More tests => 4;
use Test::Exception;

use Monad;
use Monad::Maybe;

my $fail;
lives_ok {
  $fail = mdo {
    mbind $x = Just 1;
    mbind $y = Nothing;
    mbind Just 3;
    die "This doesn't get called!: ($x, $y)\n";
    munit "This return value is not seen";
    };
  } 'Failing chain lives';

isa_ok($fail, 'Monad::Nothing');

my $ok = mdo {
    mbind $x = Just 1;
    mbind $y = Just 2;
    mbind Just "whatever";
    munit $x+$y;
    };
isa_ok($ok, 'Monad::Just');
is ($$ok, 3, 'Monadic addition');

