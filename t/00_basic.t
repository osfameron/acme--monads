#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;

use Test::More tests=>5;

BEGIN {
  use_ok 'Monad';
  use_ok 'Monad::Maybe';
  use_ok 'Monad::List';
  use_ok 'Monad::Reader';
  use_ok 'Monad::Writer';
}

