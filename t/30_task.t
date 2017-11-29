#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

require_ok( 'Werk::Task' );

can_ok( 'Werk::Task', qw( id title description ) );

throws_ok( sub { Werk::Task->new( id => '' )->run() }, 'Moose::Exception::Legacy' );

done_testing();
