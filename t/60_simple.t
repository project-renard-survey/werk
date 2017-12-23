#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Log::Log4perl qw( :easy );

Log::Log4perl->easy_init( $INFO );

require_ok( 'Werk::Flow' );
require_ok( 'Werk::ExecutorFactory' );

require_ok( 'Werk::Task::Code' );
require_ok( 'Werk::Task::Dummy' );
require_ok( 'Werk::Task::Shell' );
require_ok( 'Werk::Task::Sleep' );

my $flow = Werk::Flow->new(
	title => 'Dataload',
	description => 'Sample for a simple DAG'
);

isa_ok( $flow, 'Werk::Flow' );
can_ok( $flow, qw( add_deps  ) );

{
	my $load = Werk::Task::Shell->new(
		id => 'load',
		script => 'date'
	);

	my $enrich = Werk::Task::Sleep->new(
		id => 'enrich',
		seconds => 2
	);

	my $reduce = Werk::Task::Sleep->new(
		id => 'reduce',
		seconds => 1
	);

	my $save = Werk::Task::Code->new(
		id => 'save',
		code => sub {
			my ( $t, $c ) = @_;

			my $load = $c->get_result( 'load' );
			my @lines = map { uc( $_ ) }
				grep { $_=~ /^d/ }
				split( "\n", $load->{stdout} );

			return \@lines;
		}
	);

	my $sleep = Werk::Task::Sleep->new(
		id => 'sleep',
		seconds => 1,
	);

	$flow->add_deps( $load, $enrich, $reduce );
	$flow->add_deps( $reduce, $sleep );
	$flow->add_deps( $sleep, $save );
	$flow->add_deps( $enrich, $save );

	# $flow->draw( 'dag.svg', 'svg' );
}

{
	my $data = {
		name => 'Bruce Wayne',
		alias => 'Batman',
	};

	my $executor = Werk::ExecutorFactory->create( 'Local' );
	isa_ok( $executor, 'Werk::Executor' );
	can_ok( $executor, qw( execute ) );

	# $scheduler->draw( $flow, 'svg', 'plan.svg' );

	my $context = $executor->execute( $flow, $data );

	# use Data::Dumper;
	# warn( Dumper( $context ) );
}

done_testing();
