# -*- perl -*- mode, please, emacs


package DB::Main::A;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('a');
__PACKAGE__->add_columns
	("att",
	 { data_type => "text",  # note: DB-specific.
	 });

package DB::Main;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/A/);

package DBICTestModel;

use base qw(Exporter);
our @EXPORT = qw($A);
use vars qw($A);

($A) = map {
	my $x = $_->new;
	my $rs = $x->result_source_instance;
	$rs;
} qw(DB::Main::A);

1;
