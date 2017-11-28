package Werk::Scheduler::Linear {
	use Moose;

	extends 'Werk::Scheduler';

	with 'MooseX::Log::Log4perl';

	sub schedule {
		my ( $self, $dag, $context ) = @_;

		foreach my $task ( $dag->graph()->topological_sort() ) {
			$self->log()->info(
				sprintf( 'Executing "%s" of type %s', $task->id(), ref( $task ) )
			);

			my $result = $self->run_with_timeout( $task, $context );
			$context->set_key( $task->id(), $result );
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
