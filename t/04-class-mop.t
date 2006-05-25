#!/usr/bin/perl -w

use strict;

use Test::Depends
    [ Moose => 0.05 ],
    qw(JSON Template Template::Provider::FromDATA);

use Test::More tests => 4;

use lib "t";
use MooseTestModel;
use FromDataProcess;

my $output = $process->("base", { class => $A, method => "foo" });
is($output, "This is a/foo\n", ".include");

$output = $process->("base", { class => $B, method => "foo" });
is($output, "This is b/foo\nThis is a/foo\n", ".include");

$output = $process->("attr", { class => $B, method => "foo",
			       attr => "att" });
is($output, ("This is b/att/foo\nThis is a/att/foo\n"
	     ."This is object/types/str/foo\n"),
   ".include (attribute)");

$output = $process->("invoke", { object => B->new, method => "foo",
				 attr => "att" });
is($output, ("This is b/att/foo\nThis is a/att/foo\n"
	     ."This is object/types/str/foo\n"),
   ".invoke (attribute)");

__DATA__

__base__
[% USE Heritable -%]
[% Heritable.include(class, method) -%]
__attr__
[% USE Heritable -%]
[% Heritable.include([class, attr], method) -%]
__invoke__
[% USE Heritable -%]
[% Heritable.invoke([object, attr], method) -%]
