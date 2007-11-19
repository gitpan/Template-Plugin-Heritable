
my $oldwarn = $SIG{__WARN__} || sub { warn @_ };

$SIG{__WARN__} = sub {
	if ( $_[0] =~ m{\QCalled UNIVERSAL::can() as a function\E}) {
		#oh, please, stfu!
	}
	else {
		$oldwarn->(@_);
	}
};

1;
