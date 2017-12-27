package Werk::Task {
	use Moose;

	use MooseX::AbstractMethod;

	use Time::Out;

	use Sub::Retry;

	use Werk::Exception::TaskTimeout;

	has 'id' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	has 'title' => (
		is => 'rw',
		isa => 'Str',
		default => sub { ref( shift() ) },
	);

	has 'description' => (
		is => 'rw',
		isa => 'Maybe[Str]',
		default => undef,
	);

	has 'timeout' => (
		is => 'ro',
		isa => 'Int',
		default => 60, #seconds
	);

	has 'retries' => (
		is => 'ro',
		isa => 'Int',
		default => 1,
	);

	has 'retry_delay' => (
		is => 'ro',
		isa => 'Int',
		default => 1, # seconds
	);

	with 'MooseX::Log::Log4perl';

	abstract( 'run' );

	sub run_wrapper {
		my ( $self, $context ) = @_;

		my $result = retry( $self->retries(), $self->retry_delay(),
			sub {
				my $n = shift();

				$self->log()->debug( sprintf( '= Attempt %d', $n ) );

				my $out = Time::Out::timeout(
					$self->timeout(),
					sub { $self->run( $context ) }
				);

				Werk::Exception::TaskTimeout->throw(
					id => $self->id(),
					timeout => $self->timeout(),
				) if( $@ );

				return $out;
			}
		);

		return $result;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Task

=head1 ATTRIBUTES

=head2 id

=head2 title

=head2 description

=head2 timeout

=head2 retries

=head2 retry_delay

=head1 METHODS

=head2 run_wrapper

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
