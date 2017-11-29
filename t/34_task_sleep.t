#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Sleep' );

my $task = Werk::Task::Sleep->new(
	id => 'Sleep',
	seconds => 1,
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Sleep' );
can_ok( $task, qw( id run seconds ) );

my $output = $task->run( Werk::Context->new() );
ok( $output > 1.0, 'Actually took more than one second.' );

done_testing();
