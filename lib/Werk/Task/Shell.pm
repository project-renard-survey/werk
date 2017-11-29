package Werk::Task::Shell {
	use Moose;

	extends 'Werk::Task';

	use File::Temp qw( tempfile );
	use File::Slurp qw( write_file );

	use Capture::Tiny ':all';

	has 'script' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	has 'env' => (
		is => 'ro',
		isa => 'HashRef[Str]',
		default => sub { {} },
	);

	sub run {
		my ( $self, $context ) = @_;

		# TODO: Inject variables inside the script

		my ( $fh, $file ) = tempfile();
		write_file( $file, { binmode => ':raw' }, $self->script() );

		my ( $out, $err, $code ) = capture {
			system( 'bash', $file )
		};

		return {
			stdout => $out,
			stderr => $err,
			code => $code,
		};
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
