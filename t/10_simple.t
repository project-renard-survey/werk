#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

use Log::Log4perl qw( :easy );

Log::Log4perl->easy_init( $INFO );

require_ok( 'Werk::DAG' );
require_ok( 'Werk::Context' );
require_ok( 'Werk::SchedulerFactory' );

require_ok( 'Werk::Task::Code' );
require_ok( 'Werk::Task::Dummy' );
require_ok( 'Werk::Task::Die' );
require_ok( 'Werk::Task::Shell' );
require_ok( 'Werk::Task::Sleep' );

my $dag = Werk::DAG->new(
	title => 'Data load',
	description => 'Sample for a simple DAG'
);

isa_ok( $dag, 'Werk::DAG' );
can_ok( $dag, qw( add_deps  ) );

{
	my $load = Werk::Task::Shell->new(
		id => 'load',
		script => 'ls -al',
	);

	my $enrich = Werk::Task::Sleep->new( id => 'enrich', seconds => 5 );
	my $reduce = Werk::Task::Sleep->new( id => 'reduce', seconds => 3 );

	my $save = Werk::Task::Code->new(
		id => 'save',
		code => sub {
			my ( $context, $parent ) = @_;

			my $load = $context->get_key( 'load' );

			my @lines = map { uc( $_ ) }
				grep { $_ =~ /^d/ }
				split( "\n", $load->{stdout} );

			return \@lines;
		}
	);

	my $sleep = Werk::Task::Sleep->new(
		id => 'sleep',
		seconds => 3,
	);

	$dag->add_deps( $load, $enrich, $reduce );
	$dag->add_deps( $reduce, $sleep );
	$dag->add_deps( $sleep, $save );
	$dag->add_deps( $enrich, $save );

	$dag->draw( 'simple.svg', 'svg' );
}

{
	my $data = {
		name => 'Bruce Wayne',
		alias => 'Batman',
	};

	my $context = Werk::Context->new( data => $data );
	isa_ok( $context, 'Werk::Context' );

	my $scheduler = Werk::SchedulerFactory->create( 'Parallel' );
	isa_ok( $scheduler, 'Werk::Scheduler' );
	can_ok( $scheduler, qw( schedule ) );

	$scheduler->schedule( $dag, $context );

	# use Data::Dumper;
	# warn( Dumper( $context ) );
}

done_testing();
