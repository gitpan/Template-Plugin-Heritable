package FromDataProcess;

use Template::Provider::FromDATA;
use Template::Constants qw( :status );
use strict 'vars', 'subs';

sub import {
    my $pkg = shift;
    my $caller = caller;

    my $process = do
	{
	    my $fromdata_provider = Template::Provider::FromDATA->new
		( { CLASSES => $caller } );

	    my $normal_provider = Template::Provider->new
		({ INCLUDE_PATH => 't/ttdir' });

	    my $debug_provider = bless {}, __PACKAGE__;

	    my $output;
	    my $template = Template->new
		( {
		   # ...
		   LOAD_TEMPLATES => [ $debug_provider,
				       $normal_provider,
				       $fromdata_provider,
				     ],
		   OUTPUT => \$output,
		  } );

	    sub {
		$output = "";
		$template->process(@_)
		    or die $template->error;
		return $output
	    }
	};

    *{$caller."::process"} = \$process;
}

our $AUTOLOAD;

sub fetch {
    my $self = shift;
    my $template = shift;
    #print STDERR "$self: loading $template\n";
    return (undef, STATUS_DECLINED);
}

1;
