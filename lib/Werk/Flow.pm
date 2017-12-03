package Werk::Flow {
	use Moose;

	use Graph;
	use GraphViz2;

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

	sub add_deps {
		my ( $self, $from, @to ) = @_;

		$self->graph()->add_edge( $from, $_ )
			foreach( @to );
	}

	sub draw {
		my ( $self, $output, $format ) = @_;

		my $graph = GraphViz2->new(
			global => {
				directed => 1,
			},
			node => {
				shape => 'box',
				style => 'rounded',
			}
		);

		$graph->add_node(
			name => $_->id(),
			label => [
				{ text => sprintf( '{%s', $_->id() ) },
				{ text => sprintf( '%s', $_->title() ) },
				{ text => sprintf( '%s}', $_->description() || 'No description' ) },
			]
		) foreach( $self->graph()->vertices() );

		$graph->add_edge( from => $_->[0]->id(), to => $_->[1]->id() )
			foreach( $self->graph()->edges() );

		$graph->run(
			format => $format || 'svg',
			output_file => $output,
		);
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
