package Werk::Task::Dummy {
	use Moose;

	extends 'Werk::Task';

	with 'MooseX::Log::Log4perl';

	sub run {
		my ( $self, $context ) = @_;

		return undef;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Task::Dummy

=head1 METHODS

=head2 run

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
