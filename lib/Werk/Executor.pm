package Werk::Executor {
	use Moose;

	use MooseX::AbstractMethod;

	use forks ( exit => 'threads_only' );
	use forks::shared;

	use Class::Load qw( load_class );

	use Werk::Context;

	abstract( 'get_execution_plan' );

	with 'MooseX::Log::Log4perl';

	sub execute {
		my ( $self, $flow, $params ) = @_;

		my $context = Werk::Context->new(
			executor => ref( $self ),
			globals => $params || {},
			status => 'running',
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

					# FIXME: It seems that the returned object is not blessed correctly and
					#  even if Data::Dumper seems to show that the object has the correct type
					# in fact is not a proper Moose object. This could be a problem in the future
					# if we need to pass objects from the custom tasks.

					if( defined( $result ) && ref( $result ) eq 'Werk::Result::Abort' ) {
						my $class = blessed( $result );
						load_class( $class );
						$class->meta()->rebless_instance( $result );

						$self->log()->warn( $result->message() );
						$context->status( 'aborted' ) && return $context;
					}

					$context->set_result( $id => $result );
				}
			} else {
				$self->log()->debug( sprintf( '+ Running 1 task in stage: %d', $index ) );

				# NOTE: This is an simple optimization, no need to create a
				# new process for a single task.
				my $task = shift( @{ $stage } );

				$self->log()->debug( sprintf( '- Task: %s', $task->id() ) );
				my $result= $task->run_wrapper( $context );

				if( defined( $result ) && ref( $result ) eq 'Werk::Result::Abort' ) {
					$self->log->warn( $result->message() );
					$context->status( 'aborted' ) && return $context
				}

				$context->set_result( $task->id(), $result );
			}

			$index++;
		}

		$context->status( 'success' );
		return $context;
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

=head1 METHODS

=head2 execute

=head2 draw

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
