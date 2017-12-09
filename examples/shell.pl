#!/usr/bin/env perl

use strict;
use warnings;

use Log::Log4perl qw( :easy );

use Werk::Flow;
use Werk::Task::Shell;
use Werk::Task::Code;
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

foreach my $index ( 1 .. 5 ) {
	my $task = Werk::Task::Shell->new(
		id => sprintf( 'task_%d', $index ),
		script => 'echo -n "{$id}" && sleep 1',
	);

	$flow->add_deps( $task, $after );
}

my $last = Werk::Task::Code->new(
	id => 'last',
	code => sub {
		my ( $c, $t) = @_;

		use Data::Dumper;
		print( Dumper( $c->serialize() ) );
	}
);

$flow->add_deps( $after, $last );

Werk::ExecutorFactory->create( 'Parallel', { max_parallel_tasks => 5 } )
	->execute( $flow );
