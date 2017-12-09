#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
	module_name => 'Werk',

	dist_author => 'Tudor Marghidanu',
	dist_abstract => 'DAGs in Perl',

	share_dir => 'share',

	# NOTE: Keep list sorted!
	requires => {
		'Capture::Tiny' => undef,
		'Data::UUID' => undef,
		'File::Slurp' => undef,
		'File::Temp' => undef,
		'forks::shared' => undef,
		'forks' => undef,
		'Graph' => undef,
		'GraphViz2' => undef,
		'Moose' => undef,
		'MooseX::AbstractFactory' => undef,
		'MooseX::AbstractMethod' => undef,
		'MooseX::Log::Log4perl' => undef,
		'MooseX::Storage' => undef,
		'Sub::Retry' => undef,
		'Sys::Info::Base' => undef,
		'Sys::Info::Driver::Linux' => undef,
		'Test::Exception' => undef,
		'Test::More' => undef,
		'Test::Pod::Coverage' => undef,
		'Text::Template' => undef,
		'Time::HiRes' => undef,
		'Time::Out' => undef,
	},

	optional => { },
);

$builder->create_build_script();
