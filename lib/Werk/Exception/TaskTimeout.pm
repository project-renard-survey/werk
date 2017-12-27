package Werk::Exception::TaskTimeout {
	use Moose;

	with 'Throwable';

	has 'id' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	has 'timeout' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	__PACKAGE__->meta()->make_immutable();
}

1;
