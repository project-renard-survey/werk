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

require_ok( 'Werk::Scheduler' );
require_ok( 'Werk::SchedulerFactory' );
require_ok( 'Werk::Scheduler::Linear' );
require_ok( 'Werk::Scheduler::Parallel' );

done_testing();
