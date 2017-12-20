package Werk::Result::Abort {
	use Moose;

	extends 'Werk::Result';

	has 'message' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Result::Abort

=head1 ATTRIBUTES

=head2 message

=head1 METHODS

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
