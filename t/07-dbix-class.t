#!/usr/bin/perl -w

use strict;

use lib "t";
use Test::Depends
    qw(AnyMRO Class::C3 Template Template::Provider::FromDATA
       Test::MockObject);

use Test::More tests => 6;

use DBICTestModel;
use FromDataProcess;
use ShutUpUcan;

my $output = $process->("base", { class => $A, method => "foo" });
is($output, "This is a/foo\n", ".include");

my $a = DB::Main::A->new;
$output = $process->("invoke", { object => $a, method => "foo" });
is($output, "This is a/foo\n", ".invoke");

my $context = Test::MockObject->new();
my $tph = Template::Plugin::Heritable->new($context);

is_deeply( [grep !m{^(dbix/class/|class/data/accessor/)},
	    $tph->dispatch_paths($A, "foo")],
	   [ qw(a/foo object/foo) ],
	  "2 arg dispatch_paths");

is_deeply( [grep !m{^(dbix/class/|class/data/accessor/)},
	    $tph->dispatch_paths([$A, "att"], "foo")],
	   ([ qw(a/att/foo
		 object/att/foo
		 a/types/text/foo
		 object/types/text/foo
	       ) ]),
	   "3 arg dispatch_paths");

$output = $process->("base_attr", { class => $A, method => "foo",
			       attr => "att" });
is($output, ("This is a/att/foo\n"
	     ."This is object/types/text/foo\n"),
   ".include (attribute)");

$output = $process->("invoke_attr", { object => $a, method => "foo",
			       attr => "att" });
is($output, ("This is a/att/foo\n"
	     ."This is object/types/text/foo\n"),
   ".invoke (attribute)");

__DATA__

__base__
[% USE Heritable -%]
[% Heritable.include(class, method) -%]
__base_attr__
[% USE Heritable -%]
[% Heritable.include([class, attr], method) -%]
__invoke__
[% USE Heritable -%]
[% Heritable.invoke(object, method) -%]
__invoke_attr__
[% USE Heritable -%]
[% Heritable.invoke([object, attr], method) -%]
