package Werk::Executor::Local {
	use Moose;

	extends 'Werk::Executor';

	use threads ( exit => 'threads_only' );
	use threads::shared;

	use Werk::Context;
	use Werk::Exception::ThreadExecution;

	use Sys::Info::Device::CPU;

	has 'parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => sub {
			return Sys::Info::Device::CPU->new()
				->count() || 1;
		},
	);

	sub get_execution_plan {
		my ( $self, $flow ) = @_;

		my %tasks = map { $_->id() => $_ }
			$flow->graph()->vertices();

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

		return \@results;
	}

	sub execute {
		my ( $self, $flow, $params ) = @_;

		my $context = Werk::Context->new(
			executor => ref( $self ),
			globals => $params || {},
		);

		my @stages = @{ $self->get_execution_plan( $flow ) };

		foreach my $stage ( @stages ) {
			my %results = ();

			if( scalar( @{ $stage } ) > 1 ) {
				my @threads = ();
				push( @threads, async { [ $_->id(), $_->run_wrapper( $context ) ] } )
					foreach ( @{ $stage } );

				foreach my $thread ( @threads ) {
					my ( $id, $result ) = @{ $thread->join() };

					Werk::Exception::ThreadExecution->throw(
						id => $id,
						error => $thread->error()
					) if( $thread->error() );

					$context->set_result( $id, $result );
				}
			} else {
				# NOTE: This is an simple optimization, no need to create a new process for a single task.
				my $task = $stage->[0];

				my $result = $task->run_wrapper( $context );
				$context->set_result( $task->id(), $result );
			}
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
