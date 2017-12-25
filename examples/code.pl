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

					my $value = int( rand( $c->get_global( 'max_sleep' ) ) );
					$t->log()->debug( sprintf( 'Sleeping for %d', $value ) );
					return sleep( $value );
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

	use Log::Log4perl qw( :easy );

	use Werk::ExecutorFactory;

	Log::Log4perl->easy_init( $DEBUG );

	my $flow = CodeFlow->new(
		title => 'CodeExample',
		description => 'Workflow using Code tasks',
	);

	Werk::ExecutorFactory->create( 'Local' )
		->execute( $flow, { max_sleep => 5 } );
}
