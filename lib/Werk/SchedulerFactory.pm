package Werk::SchedulerFactory {
	use MooseX::AbstractFactory;

	implementation_class_via sub { sprintf( 'Werk::Scheduler::%s', shift() ) };
}

1;

__END__
