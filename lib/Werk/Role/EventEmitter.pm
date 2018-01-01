package Werk::Role::EventEmitter {
	use Moose::Role;

	has '_events' => (
		is => 'ro',
		isa => 'HashRef[ArrayRef[CodeRef]]',
		default => sub { {} },
		traits => [ qw( Hash ) ],
		handles => {
			'get_event' => 'get',
			'set_event' => 'set',
			'has_event' => 'defined',
			'delete_event' => 'delete',
		}
	);

	sub on {
		my ( $self, $name, $code ) = @_;

		$self->set_event( $name, [] )
			unless( $self->has_event( $name ) );

		return push( @{ $self->get_event( $name ) }, $code );
	}

	sub emit {
		my ( $self, $name, @args ) = @_;

		if( my $events = $self->get_event( $name ) ) {
			$self->$_( @args )
				foreach( @{ $events } )
		}

		return $self;
	}

	sub unsubscribe {
		my ( $self, $name, $code ) = @_;

		if( $code ) {
			$self->set_event(
				$name,
				[ grep { $_ ne $code } @{ $self->get_event( $name ) || [] } ]
			)
		} else {
			$self->delete_event( $name );
		}
	}

	no Moose::Role;
}

1;

__END__

=head1 NAME

Werk::Role::EventEmitter

=head1 METHODS

=head2 on

=head2 emit

=head2 unsubscribe

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
