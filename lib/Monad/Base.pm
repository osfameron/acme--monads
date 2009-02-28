#!/usr/bin/perl

package Monad::Base;
use strict; use warnings;

=head1 NAME

Monad::Base - base class for monads

=head1 DESCRIPTION

Base class for monads

=cut

sub mBind {
    my ($self, $f) = @_;
    return $f->($self->mJoin); # default Identity monad
}

sub mUnit {
    my ($self, $value) = @_;
    bless \$value, (ref $self) || $self;
}

sub mJoin {
    my $self = shift;
    return $$self;
}

1;
