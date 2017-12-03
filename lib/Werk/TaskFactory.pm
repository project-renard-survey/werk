package Werk::TaskFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Task::%s', shift() ) };
}

1;

__END__

=head1 NAME

Werk::TaskFactory

=head1 METHODS

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>
