#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Context' );

my $instance = Werk::Context->new();
isa_ok( $instance, 'Werk::Context' );

can_ok( $instance, qw( session_id serialize ) );

can_ok( $instance, qw( globals set_global get_global has_global ) );
can_ok( $instance, qw( results set_result get_result has_result ) );

done_testing();
