#!/usr/bin/env perl

package Werk::Task::Custom {
	use Moose;

	extends 'Werk::Task';

	sub run {
		my ( $self, $context ) = @_;

		return sprintf( 'Hello from task %s!', uc( $self->id() ) );
	}

	__PACKAGE__->meta()->make_immutable();
}

package CustomTaskFlow {
	use Moose;

	extends 'Werk::Flow';

	use Werk::Task::Sleep;
	use Werk::Task::Code;
	use Werk::Task::Dumper;

	sub BUILD {
		my $self = shift();

		my $seed = Werk::Task::Custom->new(
			id => 'seed'
		);

		my $dumper = Werk::Task::Dumper->new(
			id => 'dumper'
		);

		foreach my $index ( 1 .. 10 ) {
			my $task = Werk::Task::Sleep->new(
				id => sprintf( 'task_%d', $index ),
				seconds => int( rand( 5 ) ),
			);

			$self->add_deps( $seed, $task );
			$self->add_deps( $task, $dumper );
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Werk::ExecutorFactory;

	my $flow = CustomTaskFlow->new(
		title => 'Custom_Task',
		description => 'None',
	);

	Werk::ExecutorFactory->create( 'Local',
		{
			parallel_tasks => 5,
			flow => $flow,
		}
	)->execute( {} );
}
