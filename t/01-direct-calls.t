#!/usr/bin/perl -w

use strict;
use Test::Depends [ T2 => 0.08 ], qw(Test::MockObject);
use Template::Plugin::Heritable;
use Test::More tests => 7;

use lib "t";
use TestModel;

my $context = Test::MockObject->new();

my $tph = Template::Plugin::Heritable->new($context);

isa_ok($tph, "Template::Plugin::Heritable",
       "Template::Plugin::Heritable->new");

is_deeply( [$tph->dispatch_paths($A, "foo")],
	   [ qw(a/foo object/foo) ],
	  "2 arg dispatch_paths");

is_deeply( [$tph->dispatch_paths($B, "foo")],
	   [ qw(b/foo a/foo object/foo) ],
	   "2 arg dispatch_paths (subclass)" );

my ($P1, $P2);
is_deeply( [$tph->dispatch_paths([$A, $A->attributes(0)], "foo")],
	   ($P1 = [ qw(a/att/foo
		       object/att/foo
		       a/types/string/foo
		       object/types/string/foo
		      ) ]),
	   "3 arg dispatch_paths");

is_deeply( [$tph->dispatch_paths([$B, $A->attributes(0)], "foo")],
	   ($P2 = [ qw(b/att/foo a/att/foo
		       object/att/foo
		       b/types/string/foo
		       a/types/string/foo object/types/string/foo
		      ) ]),
	   "3 arg dispatch_paths (subclass)");

is_deeply( [$tph->dispatch_paths([$A, "att"], "foo")],
	   $P1,
	   "3 arg dispatch_paths (by name)");

is_deeply( [$tph->dispatch_paths([$B, "att"], "foo")],
	   $P2,
	   "3 arg dispatch_paths (by name, subclass)");



