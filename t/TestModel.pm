# -*- perl -*- mode, please, emacs

package TestModel;

use T2::Schema;
use base qw(Exporter);

our @EXPORT = qw($A $B $C $process);

use vars qw($A $B $C $process);

($A, $B, $C) = map { T2::Class->new(name => $_) } qw(A B C);
$B->set_superclass($A);
$C->set_superclass($B);

$A->attributes_insert(T2::Attribute->new(name => "att",
					 type => "string"));

my $schema = T2::Schema->new(classes => [ $A, $B, $C ]);

$schema->generator;

1;
