#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;

package Foo;
use Moose;

sub foo {
    shift;
    my @ret = reverse @_;
    return @ret;
}

sub bar {
    shift;
    return join '-', @_
}

package Foo::Sub;
use Moose;
use MooseX::Mangle;
extends 'Foo';

mangle_return foo => sub {
    my $self = shift;
    return wantarray ? (@_, 'd') : shift() - 1;
};

mangle_return bar => sub {
    my $self = shift;
    my ($ret) = @_;
    $ret =~ s/-/:/g;
    return $ret;
};

package main;
my $foo = Foo->new;
my $foosub = Foo::Sub->new;
is_deeply([$foo->foo(qw(a b c))], [qw(c b a)], 'unmodified method foo');
is($foo->bar(qw(a b c)), 'a-b-c', 'unmodified method bar');
is_deeply([$foosub->foo(qw(a b c))], [qw(c b a d)], "foo's args are mangled (list context)");
is(scalar $foosub->foo(qw(a b c)), 2, "foo's args are mangled (scalar context)");
is($foosub->bar(qw(a b c)), 'a:b:c', "bar's args are mangled");
