#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Context' );
require_ok( 'Werk::Task::Code' );

my $task = Werk::Task::Code->new(
	id => 'Code',
	code => sub {
		my ( $c, $t ) = @_;

		return sprintf( 'Hello from %s!', $c->get_key( 'name' ) );
	}
);

isa_ok( $task, 'Werk::Task' );
isa_ok( $task, 'Werk::Task::Code' );
can_ok( $task, qw( id run code ) );

my $context = Werk::Context->new(
	data => {
		name => 'Peter Parker'
	}
);
isa_ok( $context, 'Werk::Context' );
can_ok( $context, qw( get_key ) );

my $output = $task->run( $context );
is( $output, 'Hello from Peter Parker!' );

done_testing();
