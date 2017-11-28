package Werk::DAG {
	use Moose;

	use Graph;

	has 'title' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	has 'description' => (
		is => 'ro',
		isa => 'Maybe[Str]',
		default => undef,
	);

	has 'graph' => (
		is => 'ro',
		isa => 'Graph',
		default => sub {
			Graph->new(
				directed => 1,
				refvertexed => 1,
			);
		}
	);

	with 'Werk::Roles::Graphviz';

	sub add_deps {
		my ( $self, $from, @to ) = @_;

		$self->graph()->add_edge( $from, $_ )
			foreach( @to );
	}

	sub heads {
		my $self = shift();

		return grep { !$self->graph()->in_degree( $_ ) }
			$self->graph()->vertices();
	}

	sub tails {
		my $self = shift();

		return grep { !$self->graph()->out_degree( $_ ) }
			$self->graph()->vertices();
	}

	sub get_stages {
		my $self = shift();

		my %tasks = map { $_->id() => $_ } $self->graph()->vertices();

		my %ba;
		foreach my $edge ( $self->graph()->edges() ) {
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
