package Werk::Executor::Parallel {
	use Moose;

	extends 'Werk::Executor';

	use forks ( exit => 'threads_only' );
	use forks::shared;

	use Sys::Info::Device::CPU;

	has 'max_parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => sub {
			return Sys::Info::Device::CPU->new()
				->count() || 1;
		},
	);

	with 'MooseX::Log::Log4perl';

	sub execute {
		my ( $self, $flow, $context ) = @_;

		my @stages = $self->get_execution_plan( $flow );

		my $stage_index = 0;
		foreach my $stage ( @stages ) {

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

	sub get_execution_plan {
		my ( $self, $flow ) = @_;

		my %tasks = map { $_->id() => $_ } $flow->graph()->vertices();

		my %ba;
		foreach my $edge ( $flow->graph()->edges() ) {
			my ( $from, $to ) = map { $_->id() } @{ $edge };

			$ba{ $from }{ $to } = 1
				unless( $from eq $to );

			$ba{ $to } ||= {};
		}

		my @result = ();
		while( my @a = sort( grep { ! %{ $ba{ $_ } } } keys( %ba ) ) ) {
			push( @result, [ map { $tasks{ $_ } } @a ] );
			delete( @ba{@a} );
			delete( @{$_}{ @a } )
				foreach( values( %ba ) );
		}

		return reverse( @result );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
