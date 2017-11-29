#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Dummy' );

my $task = Werk::Task::Dummy->new(
	id => 'Dummy'
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Dummy' );
can_ok( $task, qw( id run ) );

my $output = $task->run( Werk::Context->new() );
is( $output, undef, 'No output' );

done_testing();
