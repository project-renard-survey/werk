package Werk::ExecutorFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Executor::%s', shift() ) };
}

1;

__END__

=head1 NAME

Werk::ExecutorFactory

=head1 METHODS

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
