#!/usr/bin/perl

package Monad::Reader;
use base 'Monad::Base';

use Sub::Exporter -setup => {
    exports => [ qw/ Reader / ],
    groups => {
        default => [ qw/ Reader / ],
        }
    };

sub Reader {
    return __PACKAGE__->mUnit(@_);
}

sub mUnit {
    my ($class, $value) = @_;
    return bless sub { $value }, ref $class || $class;
}
sub ask {
    my ($class, $sub) = @_;
    return bless $sub, ref $class || $class;
}
sub hashkey {
    my ($class, $key) = @_;
    return bless sub { 
        my ($env) = @_; 
        $env ||= do { package DB; my @dummy = caller(1); warn Dumper(\@dummy, \@DB::args); shift @DB::args };
        my $result = $env->{$key}; 
        use Data::Dumper;
        warn "HASH " . Dumper($env) . " -> $key = $result";
        return $result }, 
            ref $class || $class;
}

sub mBind {
    my ($self, $f) = @_;
    return bless 
        sub { my $env = shift; 
              my $value = $self->($env);
              warn "Got value $value ($env)";
              bless sub { $f->($value, $env) }, ref $self;
            }, ref $self || $self;
}

1;
