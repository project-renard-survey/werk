package Werk::Scheduler::Parallel {
	use Moose;

	extends 'Werk::Scheduler';

	use threads ( exit => 'threads_only' );
	use threads::shared;

	has 'max_parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => 10,
	);

	with 'MooseX::Log::Log4perl';

	sub schedule {
		my ( $self, $flow, $context ) = @_;

		my $stage_index = 0;
		foreach my $stage ( $flow->get_stages() ) {

			my $batch_index = 0;
			while( my @batch = splice( @{ $stage }, 0, $self->max_parallel_tasks() ) ) {
				$self->log->debug(
					sprintf( 'Running %d tasks in batch %d for stage %d',
						scalar( @batch ),
						$batch_index,
						$stage_index,
					)
				);

				my @threads = ();
				foreach my $task ( @batch ) {
					$self->log()->debug(
						sprintf( 'Stage: %d - Running "%s" of type %s', $stage_index, $task->id(), ref( $task ) )
					);

					push( @threads,
						async {
							[ $task->id(), $self->run_with_timeout( $task, $context ) ]
						}
					);
				}

				foreach my $thread ( @threads ) {
					my ( $id, $result ) = @{ $thread->join() };

					die( $thread->error() )
						if( $thread->error() );

					$context->set_key( $id => $result );
				}

				$batch_index++;
			}

			$stage_index++;
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
