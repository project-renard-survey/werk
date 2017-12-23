package Werk::Executor::Local {
	use Moose;

	extends 'Werk::Executor';

	use forks ( exit => 'threads_only' );
	use forks::shared;

	use Werk::Context;

	use Sys::Info::Device::CPU;

	has 'parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => sub {
			return Sys::Info::Device::CPU->new()
				->count() || 1;
		},
	);

	with 'MooseX::Log::Log4perl';

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

		my @stages = ();
		while( my @a = sort( grep { ! %{ $ba{ $_ } } } keys( %ba ) ) ) {
			push( @stages, [ map { $tasks{ $_ } } @a ] );
			delete( @ba{ @a } );
			delete( @{ $_ }{ @a } )
				foreach( values( %ba ) );
		}

		my @results = reverse( @stages );

		if( $self->parallel_tasks() ) {
			my @batches = ();
			foreach my $stage ( @results ) {
				while( my @batch = splice( @{ $stage }, 0, $self->parallel_tasks() ) ) {
					push( @batches, \@batch );
				}
			}

			@results = @batches;
		}

		return @results;
	}

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
			my %results = ();

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

					$results{ $id } = $result;
				}
			} else {
				$self->log()->debug( sprintf( '+ Running 1 task in stage: %d', $index ) );

				# NOTE: This is an simple optimization, no need to create a new process for a single task.
				my $task = shift( @{ $stage } );

				$self->log()->debug( sprintf( '- Task: %s', $task->id() ) );
				my $result= $task->run_wrapper( $context );

				$results{ $task->id() } = $result;
			}

			while( my ( $id, $result ) = each( %results ) ) {
				# TODO: Rebless stuff here ... if needed
				$context->set_result( $id, $result );
			}

			$index++;
		}

		return $context;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Executor::Local

=head1 ATTRIBUTES

=head2 parallel_tasks

=head1 METHODS

=head2 get_execution_plan

=head2 execute

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
