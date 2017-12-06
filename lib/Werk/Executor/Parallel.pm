package Werk::Executor::Parallel {
	use Moose;

	extends 'Werk::Executor';

	use Sys::Info::Device::CPU;

	has 'max_parallel_tasks' => (
		is => 'ro',
		isa => 'Int',
		default => sub {
			return Sys::Info::Device::CPU->new()
				->count() || 1;
		},
	);

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
			delete( @ba{@a} );
			delete( @{$_}{ @a } )
				foreach( values( %ba ) );
		}

		my @result = ();
		foreach my $stage ( reverse( @stages ) ) {
			while( my @batch = splice( @{ $stage }, 0, $self->max_parallel_tasks() ) ) {
				push( @result, \@batch );
			}
		}

		return @result;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Executor::Parallel

=head1 ATTRIBUTES

=head2 max_parallel_tasks

=head1 METHODS

=head2 get_execution_plan

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
