package Werk::Context {
	use Moose;

	use MooseX::Storage;

	use Data::UUID;

	with Storage();

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

	around 'pack' => sub {
		my $orig = shift();
		my $self = shift();

		my $result = $self->$orig( @_ );
		delete( $result->{__CLASS__} );

		return $result;
	};

	sub serialize {
		my $self = shift();

		return $self->pack( @_ );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=head1 NAME

Werk::Context

=head1 ATTRIBUTES

=head2 session_id

=head2 data

=head1 METHODS

=head2 get_key

=head2 set_key

=head2 has_key

=head2 serialize

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
