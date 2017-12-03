#!/usr/bin/env perl

package Werk::Task::Custom {
	use Moose;

	extends 'Werk::Task';

	with 'MooseX::Log::Log4perl';

	sub run {
		my ( $self, $context ) = @_;

		# Custom code goes here ...

		return sprintf( 'Hello from task %s!', uc( $self->id() ) );
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Log::Log4perl qw( :easy );

	use Werk::Flow;
	use Werk::Task::Sleep;
	use Werk::Task::Code;
	use Werk::ExecutorFactory;

	Log::Log4perl->easy_init( $DEBUG );


	my $flow = Werk::Flow->new(
		title => '',
		descripion => '',
	);

	my $seed = Werk::Task::Custom->new(
		id => 'seed'
	);

	my $dumper = Werk::Task::Code->new(
		id => 'dumper',
		code => sub {
			my $c = shift();

			use Data::Dumper;
			print( Dumper( $c->serialize() ) );
		}
	);

	foreach my $index ( 1 .. 10 ) {
		my $task = Werk::Task::Sleep->new(
			id => sprintf( 'task_%d', $index ),
			seconds => int( rand( 5 ) ),
		);

		$flow->add_deps( $seed, $task );
		$flow->add_deps( $task, $dumper );
	}

	Werk::ExecutorFactory->create( 'Parallel', { max_parallel_tasks => 5 } )
		->execute( $flow, {} );
}
