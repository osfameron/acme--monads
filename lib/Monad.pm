#!/usr/bin/perl

package Monad;
use strict; use warnings;
use Devel::Declare;
use Sub::Name;
use B::Deparse;
use B::Hooks::EndOfScope;

$Monad::Current = undef;

=head1 SYNOPSIS

 use Monad; # to get the syntax
 use Monad::Maybe;

 mdo {
    mbind $x => Just 1;
    mbind $y => Nothing;
    print $x + $y;
    }

would desugar to

 mdo {
    mbind (Just 1, sub {
        my $x = shift;
        # note no close
        mbind (Nothing, sub {
            my $y = shift;
            print $x + $y;
    # now let's close the scopes with Scope::Guard^WB::Hooks::EndOfScope
        }
      }
    }
    # e.g. 1 + (1 * number_of_levels)

=cut

# cargo culted
sub import {
    my $class = shift;
    my $caller = caller;

    Devel::Declare->setup_for(
        $caller,
        { 
            mdo   => { const => \&parse_mdo   },
            mbind => { const => \&parse_mbind },
        }
    );

    # these will be created by D::D::MI::Simple I guess
    no strict 'refs';
    *{$caller.'::mdo'}   = sub (&) {};
    *{$caller.'::mbind'} = sub ($&) {};

    # these are plain subs, use Sub::Exporter?
    *{$caller.'::mfail'} = \&mfail;
    *{$caller.'::munit'} = \&munit;
}

# Stolen from Devel::Declare's t/method-no-semi.t / Method::Signatures
# TODO use D::D:Context::Simple
{
    our ($Declarator, $Offset);
    sub skip_declarator {
        $Offset += Devel::Declare::toke_move_past_token($Offset);
    }

    sub skipspace {
        $Offset += Devel::Declare::toke_skipspace($Offset);
    }

    sub strip_name {
        skipspace;
        if (my $len = Devel::Declare::toke_scan_word($Offset, 1)) {
            my $linestr = Devel::Declare::get_linestr();
            my $name = substr($linestr, $Offset, $len);
            substr($linestr, $Offset, $len) = '';
            Devel::Declare::set_linestr($linestr);
            return $name;
        }
        return;
    }

    sub strip_proto {
        skipspace;
    
        my $linestr = Devel::Declare::get_linestr();
        if (substr($linestr, $Offset, 1) eq '(') {
            my $length = Devel::Declare::toke_scan_str($Offset);
            my $proto = Devel::Declare::get_lex_stuff();
            Devel::Declare::clear_lex_stuff();
            $linestr = Devel::Declare::get_linestr();
            substr($linestr, $Offset, $length) = '';
            Devel::Declare::set_linestr($linestr);
            return $proto;
        }
        return;
    }

    sub strip_variable_and_assign {
        skipspace;
    
        my $linestr = Devel::Declare::get_linestr();
        if (substr($linestr, $Offset) =~ /^\s*((\$\w+)\s*(?:=))/) { 
            my $var = $2;
            substr($linestr, $Offset, length $1) = '';
            Devel::Declare::set_linestr($linestr);
            return $var;
        }
        return;
    }

    sub strip_to_eol {
        skipspace;
    
        my $linestr = Devel::Declare::get_linestr();
        my $eol = substr($linestr, $Offset, length $linestr, '');
        Devel::Declare::set_linestr($linestr);
        return $eol;
    }

    sub shadow {
        my $pack = Devel::Declare::get_curstash_name;
        Devel::Declare::shadow_sub("${pack}::${Declarator}", $_[0]);
    }

    sub inject_after_mbind {
        my $inject = shift;
        # skipspace;
        my $linestr = Devel::Declare::get_linestr;

        # my $debug = $linestr; substr($debug, $Offset, 0, '>>HERE<<'); # die $debug

        substr($linestr, $Offset, 0) = $inject;
        Devel::Declare::set_linestr($linestr);
    }

    # This parser is likely to be semi-standard
    # It will call a make_proto_unwrap, which is likely to be heavily customized
    sub parse_mdo {
        local ($Declarator, $Offset) = @_;
        skip_declarator;
        # my $name = strip_name;   # won't have a name usually
        my $proto = strip_proto; # might be the name of the monad?

        my $installer = sub (&) {
            my $f = shift;
            # my $deparse = B::Deparse->new('-p', '-sC');
            # print $deparse->coderef2text( $f );
            return $f->();
          };
        shadow($installer);
    }

    sub parse_mbind {
        local ($Declarator, $Offset) = @_;
        skip_declarator;
        my $var = strip_variable_and_assign;
        my $bound = strip_to_eol;
        $bound =~ s/[;\s]*$//;

        my $scope_injector = scope_injector_call();
        my $decl = $var ? "my $var = shift;" : '';
        my $inject = qq[ +($bound) => sub { $scope_injector; $decl ]; # }
        inject_after_mbind($inject);
        warn "parse_mbind about to shadow" if $Monad::DEBUG;

        my $installer = sub ($&) {
            my ($bound, $f) = @_;
            local $Monad::Current = $bound;
            return $bound->mBind($f);
          };
        shadow($installer);
    }

    sub mk_my_var {
        my ($sigil, $name) = @_;
        my $shift = $sigil eq '$' ?
            'shift'
          : "${sigil}{+shift}";
        return qq[my $sigil$name = $shift;];
    }

    # Set up the parser scoping hacks that allow us to omit the final
    # closing brace
    sub scope_injector_call {
        my $pkg = __PACKAGE__;
        return " BEGIN { ${pkg}::inject_scope('}') }; ";
    }
    sub inject_scope {
        # normally scope injection adds a ;.
        # we don't need that but we *do* need to close the next '}'
        my $end_of_scope = shift || ';';

        on_scope_end {
            my $linestr = Devel::Declare::get_linestr;
            return unless defined $linestr;
            my $offset = Devel::Declare::get_linestr_offset;
            substr($linestr, $offset, 0) = $end_of_scope;
            Devel::Declare::set_linestr($linestr);
            };
    }
}

sub munit {
    die "Not in a monad!" unless $Monad::Current;
    $Monad::Current->mUnit(shift);
}
sub mfail {
    die "Not in a monad!" unless $Monad::Current;
    $Monad::Current->mFail(shift);
}

1;
