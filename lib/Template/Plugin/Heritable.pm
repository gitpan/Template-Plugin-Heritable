
package Template::Plugin::Heritable;

use strict;
use warnings;

our $VERSION = "0.01";

use base qw(Template::Plugin);

=head1 NAME

Template::Plugin::Heritable - OO dispatching and inheritance for templates

=head1 SYNOPSIS

 [% USE Heritable %]

 [%# searches providers for a "view" template method on
     class (which should be a metamodel object, eg
     someobj.meta in Perl 6) %]
 [% Heritable.include(class, "view", { self = object }) %]

 [%# return list of paths it would look %]
 [% paths = Heritable.dispatch_paths(class, "view") %]

 [%# if you don't have the class of the object handy, then
     use 'invoke' instead %]
 [% Heritable.invoke(object, "method", { self = object } %]

 [%# call the next method in the inheritance tree from
     inside a template method %]
 [% next_template() %]

=head1 DESCRIPTION

C<Template::Plugin::Heritable> provides support for selecting an
appropriate template based on the class of an object.  It is also
possible to call the next template in the inheritance heirarchy/chain.

This provides a form of inheritance for template display.

The core of this is the I<template dispatch> mechanism, which deals in
terms of a suitable metamodel class.  The module currently deals in
the following metamodels; but no doubt you could fool it with modules
which encapsulate other metamodels (such as Perl 5, L<NEXT>,
L<Class::C3>, L<DBIx::Class::Schema>, etc) with minimal effort by
conforming to one of their APIs.

Eventually, no doubt these will be plugins.

=over 4

=item L<T2::Class>

T2 is the Tangram MetaModel that also drives L<Class::Tangram>

=item L<Perl6::MetaModel>

This module implements the Perl6 MetaModel in terms of Perl 5 objects,
and can be found in L<pugs>.  Currently TODO as this is a first
release, but the intention is that this module will be the second
primary supported metamodel.

=head1 CONSTRUCTION

Basic use:

 [% USE Heritable %]

Specifying all options:

 [% USE Heritable({ prefix = "mypath",
                    suffix = ".tt",
                    class2path = somefunc,
                    class_attr2path = somefunc,
                    schema = myschema
                  }) %]

Here all dispatch paths returned by C<Heritable> will be prepended
with C<mypath/>.  Also, a custom method is specified to convert from
"C<Foo::Bar>"-style class names to a C<Template::Provider> path.

There is also a C<schema> object; this object is responsible for
converting objects to classes.

Normally, you wouldn't specify most of this this - and indeed there is
the issue there that this configuration information perhaps doesn't
belong every place you make a Heritable object dispatch.

For this reason, it is recommended that you have a single template for
object dispatching, and to pass through C<self> appropriately.

 [% PROCESS invoke
      object = SomeObject
      method = "foo"
 %]

the F<invoke> template might look like:

 [% USE Heritable({ suffix = ".tt"
                  });
    Heritable.include(object.meta, method, { self = object }) -%]

=cut

use Class::Tangram;

sub new {
    my $class = shift;
    my $context = shift;
    my $config = shift || {};
    bless({ context => $context,
	    config => $config },
	  (ref $class || $class));
}

=head1 METHODS

=head2 .dispatch_paths

=head2 .include

=head2 .invoke

 [% paths = Heritable.dispatch_paths( what, "name" ) %]

 [% Heritable.include( what, "name", { ... } ) %]
 [% Heritable.invoke( object, "name", { ... } ) %]

C<.dispatch_paths> returns a list of dispatch paths for C<what>.
C<what> is a metamodel object (see L<DESCRIPTION>).

C<.include> calls the first one that actually exists in the available
template providers.  It throws a (trappable) not found error if it was
not found.

C<.invoke> assumes that the metamodel object is either available as
C<object.meta> or via C<$schema-E<gt>class(ref $object)>.  Convenient
modules to make this Just Work™ with standard Perl 5 and 6
objects/classes are yet to be written, but for T2 this should work
fine.

To figure out which template should be called to perform a function,
the class names are turned into L<Template::Provider> paths, with the
template to call ("C<view>" in the example in the synopsis) appended
to them.

For example, if the "class" object in the synopsis represents the
"Foo::Bar" class, which has superclass "Foo", the following locations
would be searched for a template (assuming you specified
C<TEMPLATE_EXTENSION = ".tt"> during your Template object
construction):

  foo/bar/view.tt
  foo/view.tt
  object/view.tt

It is also possible to dispatch based on attribute or association
types, by calling "attribute methods".  In this case, the dispatch
order also includes templates for the I<types> of the attribute or
association.

So, if you were using T2 classes and wrote:

  [% Heritable.include(class.attribute("baz"), "show") %]

Then the first of these templates found would be called (assuming
C<baz> is a property of the C<Foo> class, of type C<set>):

  foo/baz/show.tt
  object/baz/show.tt
  foo/types/set/show.tt
  object/types/set/show.tt

Note that C<foo/bar/baz/show.tt> was not searched for, even though
C<class> is actually C<Foo::Bar>.  If you wanted to do that, you
should use a 'multiple invocant' C<include>:

  [% Heritable.include([class, class.attribute("baz")],
                       "show", { ... }) %]

or simply

  [% Heritable.include([class, "baz"], "show", { ... }) %]

Either of these would then search for:

  foo/bar/baz/show.tt
  foo/baz/show.tt
  object/baz/show.tt
  foo/bar/types/set/show.tt
  foo/types/set/show.tt
  object/types/set/show.tt

In principle, if an attribute's type is itself a type with an
inheritance chain, that those extra templates will also be added to
the list of checked template locations.  This will apply later in
later T2 versions and/or the Perl 6 MetaModel, when an actual type
heirarchy is in place.

=cut

use Scalar::Util qw(blessed);
use Carp qw(carp croak confess);

sub dispatch_paths {
    my $self = shift;
    my $thingy = shift;
    my $method = shift;

    my ($class, $property);
    if ( ref $thingy and ref $thingy eq "ARRAY" ) {
	($class, $property) = @$thingy;
	if ( !blessed $property ) {
	    my $t_property = ($class->get_attribute($property) ||
			      $class->get_association($property))
		or croak("class ".$class->get_name." has no property ".
			 "'$property'");
	    $property = $t_property;
	}
    }
    elsif ( !blessed $thingy ) {
	croak("'$thingy' is not even blessed, how can I dispatch?");
    }
    elsif ( $thingy->can("get_subclasses") ) {
	$class = $thingy;
    }
    elsif ( $thingy->can("get_class") ) {
	$class = $thingy->get_class;
	$property = $thingy;
    } else {
	croak("don't know how to dispatch on a $thingy");
    }

    if ( $property ) {
	return $self->_attr_dispatch_paths($class, $property, $method);
    } else {
	return $self->_class_dispatch_paths($class, $method);
    }
}

sub prefix {
    my $self = shift;
    if ( @_ ) {
	$self->{config}{prefix} = shift;
    } else {
	my $prefix = $self->{config}{prefix} || "";
	$prefix =~ s{([^/])$}{$1/};
	return $prefix;
    }
}

sub tt_ext {
    my $self = shift;
    $self->{context}{TEMPLATE_EXTENSION}||"";
}

sub _class_supers {
    my $self = shift;
    my $class = shift or confess "no class passed to _class_supers";

    # get superclasses
    my @class_order = $class;
    my $head = $class;
    while ( $head = $head->get_superclass ) {
	push @class_order, $head;
    }

    return @class_order;
}

sub class2path {
    my $self = shift;
    return $self->{class2path} ||= do {
	my $prefix = $self->prefix;
	sub {
	    ($prefix.
	     ($self->{config}{class2path} || sub {
		  (my $class = shift) =~ s{::}{/}g;
		  $prefix.lc($class);
	      })->(@_));
	};
    };
}

sub class_attr2path {
    my $self = shift;
    return $self->{class_attr2path} ||= do {
	my $prefix = $self->prefix;
	sub {
	    ($prefix.
	     ($self->{config}{class_attr2path} || sub {
		  (my $class = shift) =~ s{::}{/}g;
		  (my $what = shift) =~ s{::}{/}g;
		  my $is_type = shift;
		  $prefix.lc($class)."/".($is_type?"types/":"").lc($what);
	      })->(@_));
	};
    };
}

sub _class_dispatch_paths {
    my $self = shift;
    my $class = shift;
    my $method = shift;

    my @supers = $self->_class_supers($class);
    my $make_path = $self->class2path;
    my $tt = $self->tt_ext;

    return ( ( map {( $make_path->($_)."/$method$tt" )}
	       (map { $_->get_name } @supers), "object" ),
	   );
}

sub _attr_dispatch_paths {
    my $self = shift;
    my $class = shift;
    my $attribute = shift;
    my $method = shift;

    my @supers = $self->_class_supers($class);

    my $make_path = $self->class_attr2path;

    my $att_name = $attribute->get_name;
    my $type = $attribute->get_type;
    my $tt = $self->tt_ext;

    return ( ( map {( $make_path->($_, $att_name)
		      ."/$method$tt" )}
	       (map { $_->get_name } @supers), "object"
	     ),
	     ( map {( $make_path->($_, $type, 1)
		      ."/$method$tt" )}
	       (map { $_->get_name } @supers), "object"
	     ),
	   );
}

sub dispatch {
    my $self = shift;
    my @paths = $self->dispatch_paths(@_);

    for my $path ( @paths ) {
	if ( $self->{context}->template($path) ) {
	    return $path;
	}
    }
}

sub include {
    my $self = shift;
    my $invocant = shift;
    my $method = shift;
    my $vars = shift || {};

    my @paths = $self->dispatch_paths($invocant, $method);

    $self->_include_next($method, \@paths, @_);

    #my $t;
    #shift @paths while ($paths[0] and
			#!($t = $self->{context}->template($paths[0])));
#
    #$self->{context}->throw
	#("Couldn't find template method $method on $invocant")
	    #unless @paths;
#
    #$vars->{next_template} = sub {
	#$self->_include_next($method, \@paths, @_);
    #};
#
    #my $output = $self->{context}->include($t, $vars);
#
    #return $output;
}

sub invoke {
    my $self = shift;
    my $invocant = shift;

    my ($object, $property);
    if ( ref $invocant and ref $invocant eq "ARRAY" ) {
	($object, $property) = @$invocant;
    } elsif ( !blessed $invocant ) {
	croak("Can't invoke on '$invocant'");
    } else {
	$object = $invocant;
    }

    my $class;
    if ( $object->can("meta") ) {
	$class = $object->meta;
    } elsif ( my $schema = $self->{config}{schema} ) {
	$class = $schema->class(ref $object);
    } else {
	croak("Can't invoke on '$object' - no .meta and no schema");
    }

    return $self->include( ($property
			    ? [ $class, $property ]
			    : $class ), @_ );

}

=head1 DEFINED VARIABLES

=head2 next_template

These methods let you find the I<next> template to display in the
inheritance chain.

  The next template is [% next_template %]

  [% next_template.include({ ... }) %]

Note that if there is no next template you will get a nasty error.

=cut

sub _include_next {
    my $self = shift;
    my $method = shift;
    my @paths = @{(shift)};
    my $vars = shift || {};
    my $t;

    my $i = 0;
    do {
	$t = undef;
	eval {
	    $t = $self->{context}->template($paths[$i]);
	};
	$i++;
    } while ( $paths[$i] and !$t );

    $self->{context}->throw
	("Couldn't find next template method $method (tried: @paths), "
	 ."called from ".$self->{context}->stash->{component}->{name})
	    unless $t;

    @paths = @paths[$i..$#paths];

    $vars->{next_template} = @paths ? (sub {
	$self->_include_next($method, \@paths, @_);
    }) : sub {
	$self->{context}->throw("tried to call next_method from last "
				."link in inheritance chain");
    };

    my $output = $self->{context}->include($t, $vars);

    return $output;
}

1;

__END__

=head1 SEE ALSO

L<T2>, L<Template>.

=head1 AUTHOR

Sam Vilain, <samv@cpan.org>

=head1 LICENSE

Copyright (c) 2005, Catalyst IT (NZ) Ltd.  This program is free
software; you may use it and/or redistribute it under the same terms
as Perl itself.

=cut

