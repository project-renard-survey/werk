package Werk::Task::Shell {
	use Moose;

	extends 'Werk::Task';

	use File::Temp qw( tempfile );
	use File::Slurp qw( write_file );

	use Text::Template;

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

	has '_template' => (
		is => 'ro',
		isa => 'Text::Template',
		lazy => 1,
		default => sub {
			my $self = shift();

			return Text::Template->new(
				TYPE => 'STRING',
				SOURCE => $self->script(),
			);
		}
	);

	sub run {
		my ( $self, $context ) = @_;

		my $output = $self->_template()
			->fill_in( HASH => $context->data() );

		my ( $fh, $file ) = tempfile();
		write_file( $file, { binmode => ':raw' }, $output );

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
