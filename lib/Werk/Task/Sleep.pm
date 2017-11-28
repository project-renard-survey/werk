package Werk::Task::Sleep {
	use Moose;

	extends 'Werk::Task';

	use Time::HiRes qw( sleep );

	has 'seconds' => (
		is => 'ro',
		isa => 'Num',
		default => 0,
	);

	with 'MooseX::Log::Log4perl';

	sub run {
		my ( $self, $context ) = @_;

		my $actual = sleep( $self->seconds() );
		$self->log()
			->info( sprintf( 'Sleeping for %.4f seconds.', $actual ) );

		return $actual;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
