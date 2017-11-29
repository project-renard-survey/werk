package Werk {
	use MooseX::App;

	our $VERSION = '1.0';

	app_namespace( 'Werk::Commands' );

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
