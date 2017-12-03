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

=head1 NAME

Werk::Task

=head1 ATTRIBUTES

=head2 id

=head2 title

=head2 description

=head1 METHODS

=head2 abort

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
