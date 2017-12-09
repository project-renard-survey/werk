package Werk::Task::Code {
	use Moose;

	extends 'Werk::Task';

	has 'code' => (
		is => 'ro',
		isa => 'CodeRef',
		required => 1,
	);

	sub run {
		my ( $self, $context ) = @_;

		my $result = $self->code()
			->( $context, $self );

		return $result;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Task::Code

=head1 ATTRIBUTES

=head2 code

=head1 METHODS

=head2 run

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
