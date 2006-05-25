# -*- perl -*- mode, please, emacs

package A;
use Moose;
has 'att' => (isa => "Str", is => "rw");

package B;
use Moose;
extends 'A';

package C;
use Moose;
extends 'B';

package MooseTestModel;
use base qw(Exporter);
our @EXPORT = qw($A $B $C $process);
use vars qw($A $B $C $process);

($A, $B, $C) = map { $_->meta } qw(A B C);

1;
