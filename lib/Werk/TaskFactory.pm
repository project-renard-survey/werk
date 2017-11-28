package Werk::TaskFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Task::%s', shift() ) };
}

1;
