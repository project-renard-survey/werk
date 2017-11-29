#!/usr/bin/env perl

use Werk;
use Werk::Utils qw( dist_dir );

use Log::Log4perl;

Log::Log4perl::init( sprintf( '%s/log4perl.conf', dist_dir() ) );

Werk->new_with_command()
	->run();
