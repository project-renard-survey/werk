package Werk::ResultFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Result::%s', shift() ) };
}

1;

__END__

=head1 NAME

Werk::ResultFactory

=head1 ATTRIBUTES

=head1 METHODS

=head2 create

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
