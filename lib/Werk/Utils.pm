package Werk::Utils {
	use Moose;
	use Moose::Exporter;

	use File::ShareDir;

	Moose::Exporter->setup_import_methods(
		as_is => [ qw( dist_dir ) ]
	);

	sub dist_dir { File::ShareDir::dist_dir( 'Werk' ) }

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
