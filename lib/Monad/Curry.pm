#!/usr/bin/perl

package Monad::Curry;
use strict; use warnings;

use base 'Monad::Base';

use Sub::Exporter -setup => {
    exports => [ qw/ Curry / ],
    groups => {
        default => [ qw/ Curry / ],
        }
    };

sub Curry ($) { Monad::Curry   ->mUnit(shift) }

use overload q("") => sub { 'Curry ' . ${$_[0]} };
sub mBind {
    my ($self, $f) = @_;
    return sub { $f->(shift) }
}

1;
