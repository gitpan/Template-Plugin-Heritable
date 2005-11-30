#!/usr/bin/perl -w

use strict;

use Test::Depends
    [ T2 => 0.08 ],
    qw(JSON Template Template::Provider::FromDATA);

use Test::More tests => 3;

use lib "t";
use TestModel;
use FromDataProcess;

my $output = $process->("base", { class => $A, method => "foo" });
is($output, "This is a/foo\n", ".include");

$output = $process->("base", { class => $B, method => "foo" });
is($output, "This is b/foo\nThis is a/foo\n", ".include");

$output = $process->("attr", { class => $B, method => "foo",
			       attr => "att" });
is($output, ("This is b/att/foo\nThis is a/att/foo\n"
	     ."This is object/types/string/foo\n"),
   ".include (attribute)");

__DATA__

__base__
[% USE Heritable -%]
[% Heritable.include(class, method) -%]
__attr__
[% USE Heritable -%]
[% Heritable.include([class, attr], method) -%]
