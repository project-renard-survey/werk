package Werk::ExecutorFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Executor::%s', shift() ) };
}

1;

__END__
