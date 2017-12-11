package Werk::Flow {
	use Moose;

	use Graph;

	use GraphViz2;

	use JSON::XS qw( decode_json );

	use Class::Load qw( load_class );

	use File::Slurp qw( read_file );

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

	sub get_tasks {
		my $self = shift();

		return $self->graph()->vertices();
	}

	sub get_deps {
		my $self = shift();

		return $self->graph()->edges();
	}

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
		) foreach( $self->get_tasks() );

		$graph->add_edge( from => $_->[0]->id(), to => $_->[1]->id() )
			foreach( $self->get_deps() );

		$graph->run(
			format => $format || 'svg',
			output_file => $output,
		);
	}

	sub from_json {
		my ( $proto, $json ) = @_;
		my $class = ref( $proto ) || $proto;

		my $data = decode_json( $json );
		my $flow = $class->new( $data->{meta} || {} );

		my %tasks = ();
		foreach my $id ( keys( %{ $data->{tasks} } ) ) {
			my $definition = $data->{tasks}->{ $id };

			load_class( $definition->{class} );
			$tasks{ $id } = $definition->{class}->new(
				id => $id,
				%{ $definition->{args} || {} }
			);
		}

		$flow->add_deps(
			$tasks{ $_ },
			map { $tasks{ $_ } }
			grep { exists( $tasks{ $_ } ) }
				@{ $data->{deps}->{ $_ } }
		) foreach ( grep { exists( $tasks{ $_ } ) } keys( %{ $data->{deps} } ) );

		return $flow;
	}

	sub from_json_file {
		my ( $proto, $file ) = @_;

		my $content = read_file( $file );

		return $proto->from_json( $content );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Flow

=head1 ATTRIBUTES

=head2 title

=head2 description

=head2 graph

=head1 METHODS

=head2 get_tasks

=head2 get_edges

=head2 add_deps

=head2 draw

=head2 from_json

=head2 from_json_file

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
