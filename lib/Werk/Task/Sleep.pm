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

		my $actual = sleep( $self->seconds() );

		return $actual;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
