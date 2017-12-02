package Werk::Executor::Parallel {
	use Moose;

	extends 'Werk::Executor';

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
