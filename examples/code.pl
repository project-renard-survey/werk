#!/usr/bin/env perl

package CodeFlow {
	use Moose;

	extends 'Werk::Flow';

	use Werk::Task::Code;
	use Werk::Task::Dumper;

	sub BUILD {
		my $self = shift();

		my $dumper = Werk::Task::Dumper->new(
			id => 'last'
		);

		foreach my $index ( 1 .. 10 ) {
			my $task = Werk::Task::Code->new(
				id => sprintf( 'task_%d', $index ),
				code => sub {
					my ( $t, $c ) = @_;

					return sleep( int( rand( $c->get_global( 'max_sleep' ) ) ) );
				}
			);

			$self->add_deps( $task, $dumper );
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Werk::ExecutorFactory;

	my $flow = CodeFlow->new(
		title => 'CodeExample',
		description => 'Workflow using Code tasks',
	);

	Werk::ExecutorFactory->create( 'Local', {} )
		->execute( $flow, { max_sleep => 5 } );
}
