package Werk::Roles::Graphviz {
	use Moose::Role;

	use GraphViz2;

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

	no Moose::Role;
}

1;
