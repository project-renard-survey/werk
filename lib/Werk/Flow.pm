package Werk::Flow {
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

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
