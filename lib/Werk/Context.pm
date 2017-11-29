package Werk::Context {
	use Moose;

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

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__
