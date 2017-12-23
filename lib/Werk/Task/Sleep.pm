package Werk::Task::Sleep {
	use Moose;

	extends 'Werk::Task';

	use Time::HiRes qw( sleep );

	has 'seconds' => (
		is => 'ro',
		isa => 'Num',
		default => 0,
	);

	sub run {
		my ( $self, $context ) = @_;

		return sleep( $self->seconds() );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Task::Sleep

=head1 ATTRIBUTES

=head2 seconds

=head1 METHODS

=head2 run

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
