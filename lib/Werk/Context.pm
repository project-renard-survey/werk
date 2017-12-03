package Werk::Context {
	use Moose;

	use MooseX::Storage;

	with Storage();

	has 'data' => (
		is => 'ro',
		isa => 'HashRef',
		default => sub { {} },
		traits => [ qw( Hash ) ],
		handles => {
			'set_key' => 'set',
			'get_key' => 'get',
			'has_key' => 'exists',
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
