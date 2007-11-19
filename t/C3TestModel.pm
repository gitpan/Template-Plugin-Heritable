# -*- perl -*- mode, please, emacs

package Ay;
use Class::C3;
sub new { my $class = shift; return bless { @_ }, $class }

package Be;
use base 'Ay';
use Class::C3;

package Ce;
use base 'Be';
use Class::C3;

package C3TestModel;

Class::C3::initialize();

use base qw(Exporter);
our @EXPORT = qw($A $B $C);
use vars qw($A $B $C);

for my $class (qw(Ay Be Ce)) {
    ${substr $class, 0, 1} = $class->new;
}

1;
