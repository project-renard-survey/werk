#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

require_ok( 'Werk::Flow' );
require_ok( 'Werk::Context' );

require_ok( 'Werk::Task' );
require_ok( 'Werk::TaskFactory' );
require_ok( 'Werk::Task::Code' );
require_ok( 'Werk::Task::Shell' );
require_ok( 'Werk::Task::Dummy' );
require_ok( 'Werk::Task::Sleep' );

require_ok( 'Werk::Executor' );
require_ok( 'Werk::ExecutorFactory' );
require_ok( 'Werk::Executor::Local' );

done_testing();
