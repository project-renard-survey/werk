package Werk::Task::Code {
	use Moose;

	extends 'Werk::Task';

	has 'code' => (
		is => 'ro',
		isa => 'CodeRef',
		required => 1,
	);

	with 'MooseX::Log::Log4perl';

	sub run {
		my ( $self, $context ) = @_;

		$self->log()->info( 'Executing anonymous code' );
		return $self->code()->( $context, $self );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
