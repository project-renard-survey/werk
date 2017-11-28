package Werk::Task::Dummy {
	use Moose;

	extends 'Werk::Task';

	sub run {
		my ( $self, $context ) = @_;

		return sprintf( 'Just a dummy task with id: "%s"', $self->id() );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
