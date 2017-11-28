#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Moose;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Shell' );

my $task = Werk::Task::Shell->new(
	id => 'Shell',
	script => 'apt-get update',
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Shell' );
can_ok( $task, qw( id run ) );

my $output = $task->run( Werk::Context->new() );

use Data::Dumper;
warn( Dumper( $output ) );

done_testing();
