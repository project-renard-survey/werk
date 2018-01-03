package Werk::Context {
	use Moose;

	use Data::UUID;
	use Data::PathSimple qw( get );

	has 'session_id' => (
		is => 'ro',
		isa => 'Str',
		default => sub {
			return Data::UUID->new()
				->create_str()
		}
	);

	has 'globals' => (
		is => 'ro',
		isa => 'HashRef',
		default => sub { {} },
		traits => [ qw( Hash ) ],
		handles => {
			set_global => 'set',
			get_global => 'get',
			has_global => 'exists',
		}
	);

	has 'results' => (
		is => 'ro',
		isa => 'HashRef',
		default => sub { {} },
		traits => [ qw( Hash ) ],
		handles => {
			set_result => 'set',
			get_result => 'get',
			has_result => 'exists',
		}
	);

	has 'executor' => (
		is => 'ro',
		isa => 'Maybe[Str]',
		default => undef,
	);

	has 'created' => (
		is => 'ro',
		isa => 'Num',
		default => sub { time() },
	);

	sub get_result_path {
		my ( $self, $path ) = @_;

		return get( $self->results(), $path || '/' );
	}

	sub get_global_path {
		my ( $self, $path ) = @_;

		return get( $self->globals(), $path || '/' );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Context

=head1 ATTRIBUTES

=head2 session_id

=head2 globals

=head2 results

=head2 executor

=head2 created

=head1 METHODS

=head2 get_global

=head2 set_global

=head2 has_global

=head2 get_result

=head2 set_result

=head2 has_result

=head2 get_result_path

=head2 get_global_path

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
