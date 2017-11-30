package Werk::Executor {
	use Moose;

	use MooseX::AbstractMethod;

	use Time::Out qw( timeout );

	has 'task_timeout' => (
		is => 'ro',
		isa => 'Int',
		default => 60,
	);

	abstract( 'execute' );

	sub run_with_timeout {
		my ( $self, $task, $context ) = @_;

		# TODO: Account for number of retries

		my $result = timeout(
			$self->task_timeout(),
			sub { $task->run( $context ) },
		);

		die( sprintf( 'Call to %s timed out after %d seconds', $task->id(), $self->task_timeout() ) )
			if( $@ );

		return $result;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
