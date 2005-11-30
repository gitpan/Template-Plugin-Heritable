#!/usr/bin/perl -w

use strict;
use Test::Depends
    [ T2 => 0.10 ],
    qw(JSON Template),
    [ qw(Template::Provider::FromDATA) => 0.04 ];

use Test::More tests => 6;

use lib "t";
use TestModel;
use FromDataProcess;

is($process->("test", {}), "This is a test!\n\n",
   "Sanity check T::P::FromDATA");

my $jprocess = sub { my $data = $process->(@_);
		     #diag($data);
		     return jsonToObj($data); };

is_deeply( $jprocess->("dispatch_paths", { class => $A, method => "foo" }),
	   [ qw(a/foo object/foo) ],
	   "2 arg dispatch_paths");

is_deeply( $jprocess->("dispatch_paths3",
		       { class => $A,
			 attribute => $A->get_attribute("att"),
			 method => "foo" }),
	   [ qw(a/att/foo
		object/att/foo
		a/types/string/foo
		object/types/string/foo
	       ) ],
	   "3 arg dispatch_paths");

is_deeply( $process->("include", { class => $A, method => "foo" }),
	   "This is a/foo\n",
	   "2 arg include" );

my $a = $A->get_name->new;
my $schema = $A->get_schema;

is_deeply( $process->("invoke", { object => $A->get_name->new,
				  schema => $A->get_schema,
				  method => "foo" }),
	   "This is a/foo\n",
	   "2 arg invoke w/schema" );

eval { $process->("invoke", { object => $A->get_name->new,
			      schema => $A->get_schema,
			      method => "bar" });
   };
isnt($@, "", "errors raised properly");


__DATA__

__test__
This is a test!

__dispatch_paths__
[% USE Heritable -%]
[ [% i = 0;
   FOR path = Heritable.dispatch_paths(class, method);
     GET (i ? ", ": "");
     i = i + 1; -%]
"[% path %]"
[% END %] ]

__dispatch_paths3__
[% USE Heritable -%]
[ [% i = 0;
   FOR path = Heritable.dispatch_paths([ class, attribute ], method);
     GET (i ? ", ": "");
     i = i + 1; -%]
"[% path %]"
[% END %] ]

__include__
[% USE Heritable -%]
[% Heritable.include(class, method) -%]
__invoke__
[% USE Heritable({ "schema" = schema }) -%]
[% Heritable.invoke(object, method) -%]
__end__
