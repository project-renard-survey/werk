package Werk::Executor::Sequential {
	use Moose;

	extends 'Werk::Executor';

	with 'MooseX::Log::Log4perl';

	sub get_execution_plan {
		my ( $self, $flow ) = @_;

		return map { [ $_ ] }
			$flow->graph()->topological_sort();
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Executor::Sequential

=head1 METHODS

=head2 get_execution_plan

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
