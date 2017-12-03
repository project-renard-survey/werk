#!/usr/bin/env perl

use strict;
use warnings;

use Log::Log4perl qw( :easy );

use Werk::Flow;
use Werk::Task::Code;
use Werk::ExecutorFactory;

Log::Log4perl->easy_init( $DEBUG );

my $flow = Werk::Flow->new(
	title => 'Code Example',
	description => 'Workflow using Code tasks',
);

my $dumper = Werk::Task::Code->new(
	id => 'last',
	code => sub {
		my ( $c, $t ) = @_;

		use Data::Dumper;
		print( Dumper( $c->serialize() ) );
	}
);

foreach my $index ( 1 .. 10 ) {
	my $task = Werk::Task::Code->new(
		id => sprintf( 'task_%d', $index ),
		code => sub {
			my ( $c, $t ) = @_;

			my $value = int( rand( $c->get_key( 'max_sleep' ) ) );
			$t->log()->debug( sprintf( 'Sleeping for %d', $value ) );
			return sleep( $value );
		}
	);

	$flow->add_deps( $task, $dumper );
}

Werk::ExecutorFactory->create( 'Parallel', { max_parallel_tasks => 10 } )
	->execute( $flow, { max_sleep => 5 } );
