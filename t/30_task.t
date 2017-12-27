#!/usr/bin/env perl

package Werk::Task::Timeout {
	use Moose;

	extends 'Werk::Task';

	sub run { sleep( 2 ) }

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Test::More;
	use Test::Exception;

	require_ok( 'Werk::Task' );

	# General functionality
	can_ok( 'Werk::Task', qw( id title description run run_wrapper ) );

	throws_ok {
		Werk::Task->new( id => 'empty' )
			->run()
		} 'Moose::Exception::Legacy';

	# Timeout test
	isa_ok( 'Werk::Task::Timeout', 'Werk::Task' );

	throws_ok {
		Werk::Task::Timeout->new(
			id => 'timeout',
			timeout => 2
		)->run_wrapper()
	} 'Werk::Exception::TaskTimeout';

	done_testing();
}
