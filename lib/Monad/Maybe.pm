#!/usr/bin/perl

package Monad::Maybe;
use strict; use warnings;

use base 'Monad';

use Sub::Exporter -setup => {
    exports => [ qw/ Just Nothing / ],
    groups => {
        default => [ qw/ Just Nothing / ],
        }
    };

sub Nothing  { Monad::Nothing->mUnit() }
sub Just ($) { Monad::Just   ->mUnit(shift) }

sub mFail {
    return Nothing();
}

package Monad::Just;
our @ISA = 'Monad::Maybe';
use overload q("") => sub { 'Just ' . ${$_[0]} };
sub mBind {
    my ($self, $f) = @_;
    return $f->($self->mJoin);
}

package Monad::Nothing;
our @ISA = 'Monad::Maybe';
use overload q("") => sub { 'Nothing' };

sub mBind {
    my ($self) = @_;
    return $self; # Nothing, ignoring $f
}

1;
