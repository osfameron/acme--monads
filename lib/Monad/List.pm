#!/usr/bin/perl

package Monad::List;
use strict; use warnings;
use base 'Monad::Base';

use Sub::Exporter -setup => {
    exports => [ qw/ List guard / ],
    groups => {
        default => [ qw/ List guard / ],
        }
    };

sub List { Monad::List->mUnit(@_) }

sub guard {
    my $bool = shift;
    return $bool ? List [] : List ();
}

sub mBind {
    my ($self, $f) = @_;
    # Perl's map is already a concatMap
    return List ( map { @{ $f->($_)} } $self->mJoin );
}

sub mJoin {
    my $self = shift;
    return @$self;
}

sub mUnit {
    my ($self, @v) = @_;
    my $class = ref $self || $self;
    return bless \@v, $class;
}

sub mFail {
    my $self = shift;
    return $self->mUnit();
}

# MonadPlus instances
{ no warnings 'once'; 
*mZero = \&fail; }
sub mPlus {
    my ($self, $other) = @_;
    return $self->mUnit( @$self, @$other );
}

1;
