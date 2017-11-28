package Werk::Task::Die {
	use Moose;

	extends 'Werk::Task';

	sub run {
		die( 'Goodbye cruel world!' );
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
