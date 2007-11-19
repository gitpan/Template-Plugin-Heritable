#!/usr/bin/perl -w

use strict;

use lib "t";
use Test::Depends
    qw(AnyMRO Class::C3 Template Template::Provider::FromDATA);

use Test::More tests => 2;

use C3TestModel;
use FromDataProcess;

my $output = $process->("base", { object => $A, method => "foo" });
is($output, "This is a/foo\n", ".include");

$output = $process->("base", { object => $B, method => "foo" });
is($output, "This is b/foo\nThis is a/foo\n", ".include");

__DATA__

__base__
[% USE Heritable -%]
[% Heritable.invoke(object, method) -%]
__attr__
[% USE Heritable -%]
[% Heritable.invoke([object, attr], method) -%]
