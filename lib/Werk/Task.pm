package Werk::Task {
	use Moose;

	use MooseX::AbstractMethod;

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

	abstract( 'run' );

	sub abort {
		my $self = shift();

		return undef;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
