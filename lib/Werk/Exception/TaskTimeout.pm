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

__END__

=head1 NAME

Werk::Exception::TaskTimeout

=head1 ATTRIBUTES

=head2 id

=head2 timeout

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
