package Werk::Executor {
	use Moose;

	use MooseX::AbstractMethod;

	abstract( 'get_execution_plan' );
	abstract( 'execute' );

	has 'flow' => (
		is => 'ro',
		isa => 'Werk::Flow',
		required => 1,
	);

	has 'execution_plan' => (
		is => 'ro',
		isa => 'ArrayRef',
		lazy => 1,
		default => sub {
			my $self = shift();

			return $self->get_execution_plan(
				$self->flow()
			);
		},
	);

	sub draw {
		my ( $self, $output, $format ) = @_;

		my $graph = GraphViz2->new(
			global => {
				name => $self->flow()->title(),
				directed => 1,
			},
			node => {
				shape => 'box',
				style => 'rounded',
			},
		);

		my @stages = @{ $self->execution_plan() };

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

=head2 draw

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
