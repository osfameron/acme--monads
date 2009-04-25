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

#use overload q("") => sub { 'Curry ' . ${$_[0]} };
sub mBind {
    my ($self, $f) = @_;
    my $proto = $Monad::Proto;
    return sub { 
        local $Monad::Proto = $proto;
        # we use the generic "Monad::Proto" feature for the number of arguments
        # this is... um... a hack, experimental API
        if ($Monad::Proto) {
            die "Expected $Monad::Proto args but got " . scalar @_
                if (@_ > $Monad::Proto);
            $Monad::Proto--;
        }
        my $it = $f;
        for my $arg (@_) {
            $it = $it->($arg);
        }
        return $it; # either a function or a value
      };
}

1;
