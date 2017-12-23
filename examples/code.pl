#!/usr/bin/env perl

use strict;
use warnings;

use Log::Log4perl qw( :easy );

use Werk::Flow;
use Werk::Task::Code;
use Werk::ExecutorFactory;

Log::Log4perl->easy_init( $DEBUG );

my $flow = Werk::Flow->new(
	title => 'CodeExample',
	description => 'Workflow using Code tasks',
);

my $dumper = Werk::Task::Code->new(
	id => 'last',
	code => sub {
		my ( $t, $c ) = @_;

		use Data::Dumper;
		print( Dumper( $c ) );
	}
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

	$flow->add_deps( $task, $dumper );
}

Werk::ExecutorFactory->create( 'Local', { parallel_tasks => 0 } )
	->execute( $flow, { max_sleep => 5 } );
