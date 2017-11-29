#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Shell' );

my $task = Werk::Task::Shell->new(
	id => 'Shell',
	script => 'ls *.PL',
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Shell' );
can_ok( $task, qw( id run script ) );

my $output = $task->run( Werk::Context->new() );
isa_ok( $output, 'HASH' );

is( $output->{code}, 0 );
is( $output->{stderr}, '' );

done_testing();
