#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Shell' );

my $task = Werk::Task::Shell->new(
	id => 'Shell',
	script => 'ls {$extension}',
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Shell' );
can_ok( $task, qw( id run script ) );

my $context = Werk::Context->new(
	data => { extension => '*.PL' }
);

my $output = $task->run( $context );
isa_ok( $output, 'HASH' );

is( $output->{code}, 0 );
is( $output->{stderr}, '' );

# use Data::Dumper;
# warn( Dumper( $output ) );

done_testing();
