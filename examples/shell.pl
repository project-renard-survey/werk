#!/usr/bin/env perl

use strict;
use warnings;

use Log::Log4perl qw( :easy );

use Werk::Flow;
use Werk::Task::Shell;
use Werk::ExecutorFactory;

Log::Log4perl->easy_init( $DEBUG );

my $flow = Werk::Flow->new(
	title => 'Shell Example',
	description => 'Workflow example using Shell tasks',
);

my $after = Werk::Task::Shell->new(
	id => 'after_loop',
	script => 'echo -n 1',
);

foreach my $index ( 0 .. 5 ) {
	my $task = Werk::Task::Shell->new(
		id => sprintf( 'task_%d', $index ),
		script => 'echo -n "{$id}" && sleep 1',
	);

	$flow->add_deps( $task, $after );
}

my $last = Werk::Task::Shell->new(
	id => 'last',
	script => 'ls -al',
);

$flow->add_deps( $after, $last );

# $flow->draw( 'shell_dag.svg' );

{
	my $executor = Werk::ExecutorFactory->create( 'Parallel' );
	# $executor->draw( $flow, 'shell_plan.svg' );

	my $context = $executor->execute( $flow );

	use Data::Dumper;
	warn( Dumper( $context ) );
}
