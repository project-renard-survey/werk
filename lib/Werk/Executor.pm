package Werk::Executor {
	use Moose;

	use MooseX::AbstractMethod;

	use forks ( exit => 'threads_only' );
	use forks::shared;

	use Sys::Info::Device::CPU;

	use Time::Out qw( timeout );

	use Werk::Context;

	has 'task_timeout' => (
		is => 'ro',
		isa => 'Int',
		default => 60,
	);

	has 'max_parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => sub {
			return Sys::Info::Device::CPU->new()
				->count() || 1;
		},
	);

	abstract( 'get_execution_plan' );

	with 'MooseX::Log::Log4perl';

	sub execute {
		my ( $self, $flow, $params ) = @_;

		my $context = Werk::Context->new(
			data => $params || {}
		);

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

				if( scalar( @batch ) > 1 ) {
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
				} else {
					# NOTE: This is an simple optiomization, no need to create a
					# new process for a single task.
					my $task = shift( @batch );
					my $result= $self->run_with_timeout( $task, $context );

					$context->set_key( $task->id(), $result );
				}

				$batch_index++;
			}

			$stage_index++;
		}

		return $context;
	}

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

	sub draw {
		my ( $self, $flow, $output, $format ) = @_;

		my $graph = GraphViz2->new(
			global => {
				directed => 1,
			},
			node => {
				shape => 'box',
				style => 'rounded',
			},
		);

		my @stages = $self->get_execution_plan( $flow );

		my $previous = undef;
		foreach my $index ( 0 .. scalar( @stages ) - 1 ) {
			my $name = sprintf( 'stage_%d', $index );

			$graph->add_node(
				name => $name,
				label => sprintf( 'Stage %d', $index ),
			);

			$graph->add_edge( from => $previous, to => $name )
				if( $previous );

			foreach my $task ( @{ $stages[ $index ] } ) {
				$graph->add_node(
					name => $task->id(),
					label => $task->id(),
					shape => 'ellipse',
				);

				$graph->add_edge(
					from => $name,
					to => $task->id(),
					arrowhead => 'odot',
				);
			}

			$previous = $name;
		}

		$graph->run(
			format => $format || 'svg',
			output_file => $output,
		);

		return $self;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Executor

=head1 ATTRIBUTES

=head2 task_timeout

=head2 max_parallel_tasks

=head1 METHODS

=head2 execute

=head2 run_with_timeout

=head2 draw

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
