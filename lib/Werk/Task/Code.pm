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
