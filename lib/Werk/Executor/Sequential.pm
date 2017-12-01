package Werk::Executor::Sequential {
	use Moose;

	extends 'Werk::Executor';

	with 'MooseX::Log::Log4perl';

	sub execute {
		my ( $self, $flow, $context ) = @_;

		my @tasks = $self->get_execution_plan( $flow );

		foreach my $task ( @tasks ) {
			$self->log()->debug(
				sprintf( 'Executing "%s" of type %s', $task->id(), ref( $task ) )
			);

			my $result = $self->run_with_timeout( $task, $context );
			$context->set_key( $task->id(), $result );
		}
	}

	sub get_execution_plan {
		my ( $self, $flow ) = @_;

		return $flow->graph()
			->topological_sort();
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
