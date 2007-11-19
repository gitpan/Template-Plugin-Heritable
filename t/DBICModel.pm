# -*- perl -*- mode, please, emacs

package DB::Main;
use base qw/DBIx::Class::Schema/;

package DB::Main::A;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('a');
__PACKAGE__->add_columns
	("att",
	 { data_type => "text",  # note: DB-specific.
	 });

package DB::Main::B;
use base qw(DB::Main::A);

package DB::Main::C;
use base qw(DB::Main::B);

package MooseTestModel;

use base qw(Exporter);
our @EXPORT = qw($A $B $C);
use vars qw($A $B $C);

($A, $B, $C) = qw(A B C);

1;
