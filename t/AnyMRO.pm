our $mro;

BEGIN {
	$mro = "mro";
	eval {
		require mro;
	};
	if ( $@ ) {
		$mro = "MRO::Compat";
	}
}

use Test::Depends $mro;
