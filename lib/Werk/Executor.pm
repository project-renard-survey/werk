package Werk::Executor {
	use Moose;

	use MooseX::AbstractMethod;

	use forks ( exit => 'threads_only' );
	use forks::shared;

	use Werk::Context;

	abstract( 'get_execution_plan' );

	with 'MooseX::Log::Log4perl';

	sub execute {
		my ( $self, $flow, $params ) = @_;

		my $context = Werk::Context->new(
			executor => ref( $self ),
			globals => $params || {},
		);

		$self->log()->debug( sprintf( '* Running workflow "%s" with id: %s',
				$flow->title(),
				$context->session_id(),
			)
		);

		my @stages = $self->get_execution_plan( $flow );

		my $index = 0;
		foreach my $stage ( @stages ) {
			if( scalar( @{ $stage } ) > 1 ) {
				$self->log()->debug( sprintf( '+ Running %d tasks in parallel in stage: %d',
						scalar( @{ $stage } ),
						$index,
					)
				);

				my @threads = ();
				foreach my $task ( @{ $stage }  ) {
					$self->log()->debug( sprintf( '- Task: %s', $task->id() ) );
					push( @threads,
						async { [ $task->id(), $task->run_wrapper( $context ) ] }
					);
				}

				foreach my $thread ( @threads ) {
					my ( $id, $result ) = @{ $thread->join() };

					die( $thread->error() )
						if( $thread->error() );

					$context->set_result( $id, $result );
				}
			} else {
				$self->log()->debug( sprintf( '+ Running 1 task in stage: %d', $index ) );

				# NOTE: This is an simple optimization, no need to create a
				# new process for a single task.
				my $task = shift( @{ $stage } );

				$self->log()->debug( sprintf( '- Task: %s', $task->id() ) );
				my $result= $task->run_wrapper( $context );

				$context->set_result( $task->id(), $result );
			}

			$index++;
		}

		return $context;
	}

	sub draw {
		my ( $self, $flow, $output, $format ) = @_;

		my $graph = GraphViz2->new(
			global => {
				name => $flow->title(),
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

=head1 METHODS

=head2 execute

=head2 draw

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
