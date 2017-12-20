#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Log::Log4perl qw( :easy );

Log::Log4perl->easy_init( $INFO );

require_ok( 'Werk::Flow' );
require_ok( 'Werk::Task::Code' );
require_ok( 'Werk::Task::Dummy' );
require_ok( 'Werk::Task::Sleep' );
require_ok( 'Werk::ExecutorFactory' );

my $start= Werk::Task::Dummy->new(
	id => 'start'
);
isa_ok( $start, 'Werk::Task' );
isa_ok( $start, 'Werk::Task::Dummy' );

my $step_one = Werk::Task::Code->new(
	id => 'abort',
	code => sub {
		my ( $c, $t ) = @_;

		return $t->abort();
	},

	retries => 5,
	retry_delay => 1,
);
isa_ok( $step_one, 'Werk::Task' );
isa_ok( $step_one, 'Werk::Task::Code' );

my $step_two = Werk::Task::Sleep->new(
	id => 'sleep',
	seconds => 1,
);
isa_ok( $step_two, 'Werk::Task' );
isa_ok( $step_two, 'Werk::Task::Sleep' );

my $stop = Werk::Task::Dummy->new(
	id => 'stop'
);
isa_ok( $start, 'Werk::Task' );
isa_ok( $start, 'Werk::Task::Dummy' );

my $flow = Werk::Flow->new(
	title => 'Abort flow test',
);
isa_ok( $flow, 'Werk::Flow' );
can_ok( $flow, qw( add_deps ) );

$flow->add_deps( $start, $step_one );
$flow->add_deps( $step_one, $stop );
$flow->add_deps( $step_two, $stop );

{
	my $executor = Werk::ExecutorFactory->create( 'Parallel', {} );
	isa_ok( $executor, 'Werk::Executor' );
	isa_ok( $executor, 'Werk::Executor::Parallel' );

	my $context = $executor->execute( $flow, {} );

	# use Data::Dumper;
	# warn( Dumper( $context ) );
}

{
	my $executor = Werk::ExecutorFactory->create( 'Sequential', {} );
	isa_ok( $executor, 'Werk::Executor' );
	isa_ok( $executor, 'Werk::Executor::Sequential' );

	my $context = $executor->execute( $flow, {} );

	# use Data::Dumper;
	# warn( Dumper( $context ) );
}

done_testing();
