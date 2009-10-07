#!/usr/bin/perl -w

use strict;
use Test::Depends [ Moose => 0.05 ], qw(Test::MockObject);
use Template::Plugin::Heritable;
use Test::More tests => 7;

use lib "t";
use MooseTestModel;
use ShutUpUcan;

my $context = Test::MockObject->new();

my $tph = Template::Plugin::Heritable->new($context);

isa_ok($tph, "Template::Plugin::Heritable",
       "Template::Plugin::Heritable->new");

is_deeply( [$tph->dispatch_paths($A, "foo")],
	   [ qw(a/foo moose/object/foo object/foo) ],
	  "2 arg dispatch_paths");

is_deeply( [$tph->dispatch_paths($B, "foo")],
	   [ qw(b/foo a/foo moose/object/foo object/foo) ],
	   "2 arg dispatch_paths (subclass)" );

my ($P1, $P2);
($P1 = [ qw(a/att/foo moose/object/att/foo object/att/foo
a/types/str/foo moose/object/types/str/foo object/types/str/foo
a/types/value/foo moose/object/types/value/foo object/types/value/foo
a/types/defined/foo moose/object/types/defined/foo object/types/defined/foo
a/types/item/foo moose/object/types/item/foo object/types/item/foo
a/types/any/foo moose/object/types/any/foo object/types/any/foo
) ]);
my $got = [$tph->dispatch_paths([$A, $A->get_attribute("att")], "foo")];
my $no_any;
if ($Moose::VERSION <= 0.54 or ($Moose::VERSION < 0.88 and not grep m{/any/}, @$got)) {
	@$P1 = grep !m{/any/}, @$P1;
	$no_any = 1;
}
is_deeply( $got, $P1, "3 arg dispatch_paths");

$got = [$tph->dispatch_paths([$B, $A->get_attribute("att")], "foo")];

($P2 = [ qw(b/att/foo a/att/foo moose/object/att/foo object/att/foo
b/types/str/foo a/types/str/foo moose/object/types/str/foo object/types/str/foo
b/types/value/foo a/types/value/foo moose/object/types/value/foo object/types/value/foo
b/types/defined/foo a/types/defined/foo moose/object/types/defined/foo object/types/defined/foo
b/types/item/foo a/types/item/foo moose/object/types/item/foo object/types/item/foo
b/types/any/foo a/types/any/foo moose/object/types/any/foo object/types/any/foo
		      ) ]);
if ($no_any) {
	@$P2 = grep !m{/any/}, @$P2;
}

is_deeply( $got, $P2, "3 arg dispatch_paths (subclass)");

is_deeply( [$tph->dispatch_paths([$A, "att"], "foo")],
	   $P1,
	   "3 arg dispatch_paths (by name)");

is_deeply( [$tph->dispatch_paths([$B, "att"], "foo")],
	   $P2,
	   "3 arg dispatch_paths (by name, subclass)");



