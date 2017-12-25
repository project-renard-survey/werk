package Werk::Task::Dumper {
	use Moose;

	extends 'Werk::Task';

	use Data::Dumper;

	sub run {
		my ( $self, $context ) = @_;

		print( Dumper( $context ) );

		return undef;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Task::Dumper;

=head1 METHODS

=head2 run

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
