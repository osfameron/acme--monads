#!/usr/bin/perl

package Monad::Writer;
use base 'Monad';

use Sub::Exporter -setup => {
    exports => [ qw/ Writer / ],
    groups => {
        default => [ qw/ Writer / ],
        }
    };

sub Writer {
    return __PACKAGE__->mUnit(@_);
}

sub mUnit {
    my ($class, $x, $d) = @_;
    return bless { value => $x, debug => $d||'' }, $class;
}

sub mBind {
    my ($self, $f) = @_;
    my $r = $f->($self->mjoin);
    return bless { value => $r->{value}, debug => "$self->{debug}$r->{debug}" }, ref $self;
}

sub mJoin {
    my $self = shift;
    return $self->{value};
}

1;
