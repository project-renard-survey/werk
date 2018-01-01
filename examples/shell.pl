#!/usr/bin/env perl

package ShellFlow {
	use Moose;

	extends 'Werk::Flow';

	use Werk::Task::Shell;
	use Werk::Task::Dumper;

	sub BUILD {
		my $self = shift();

		my $after = Werk::Task::Shell->new(
			id => 'after_loop',
			script => 'echo -n 1',
		);

		foreach my $index ( 1 .. 5 ) {
			my $task = Werk::Task::Shell->new(
				id => sprintf( 'task_%d', $index ),
				script => 'echo -n "{$id}" && sleep 1',
			);

			$self->add_deps( $task, $after );
		}

		my $last = Werk::Task::Dumper->new(
			id => 'last'
		);

		$self->add_deps( $after, $last );
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Werk::ExecutorFactory;

	my $flow = ShellFlow->new(
		title => 'ShellFlow',
		description => 'Workflow example using Shell tasks',
	);

	Werk::ExecutorFactory->create( 'Local',
		{
			parallel_tasks => 5,
			flow => $flow,
		}
	)->execute( {} );
}
