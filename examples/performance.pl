#!/usr/bin/env perl

package SleeperFlow {
	use Moose;

	extends 'Werk::Flow';

	use Werk::Task::Dummy;
	use Werk::Task::Sleep;

	sub BUILD {
		my $self = shift();

		my $begin = Werk::Task::Dummy->new( id => 'begin' );
		my $middle = Werk::Task::Dummy->new( id => 'middle' );
		my $end = Werk::Task::Dummy->new( id => 'end' );

		foreach my $index ( 1 .. 5 ) {
			my $task = Werk::Task::Sleep->new(
				id => sprintf( 'task_1_%d', $index ),
				seconds => 1,
			);

			$self->add_deps( $begin, $task );
			$self->add_deps( $task, $middle );
		}

		foreach my $index ( 1 .. 5 ) {
			my $task = Werk::Task::Sleep->new(
				id => sprintf( 'task_2_%d', $index ),
				seconds => 1,
			);

			$self->add_deps( $middle, $task );
			$self->add_deps( $task, $end );
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Werk::Executor::Local;

	use Getopt::Long;

	use Time::HiRes qw( time );

	my ( $workers, $times ) = ( 0, 10 );
	GetOptions(
		'workers|w=i' => \$workers,
		'times|t=i' => \$times,
	);

	my $flow = SleeperFlow->new(
		title => 'SleeperFlow',
		description => 'Performance testing'
	);

	printf( "Executing flow with %d workers\n", $workers );
	my $executor = Werk::Executor::Local->new( parallel_tasks => $workers );

	# $executor->draw( 'performance.plan.svg' );

	foreach my $index ( 1 .. $times ) {
		my $start = time();
		$executor->execute( $flow, {} );
		printf( "Total execution time: %f on run %d\n",
			( time() - $start ),
			$index,
		);
	}
}
