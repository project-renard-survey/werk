package Werk::Exception::ThreadExecution {
	use Moose;

	with 'Throwable';

	has 'id' => (
		is => 'ro',
		isa => 'St.r',
		required => 1
	);

	has 'error' => (
		is => 'ro',
		isa => 'Any',
		required => 1,
	);

	__PACKAGE__->meta()->make_immutable();
}

1;

=head1 NAME

Werk::Exception::ThreadExecution

=head1 ATTRIBUTES

=head2 id

=head2 error

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
