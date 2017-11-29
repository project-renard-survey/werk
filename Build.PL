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
		'File::Slurp' => undef,
		'File::Temp' => undef,
		'Graph' => undef,
		'GraphViz2' => undef,
		'Moose' => undef,
		'MooseX::AbstractFactory' => undef,
		'MooseX::AbstractMethod' => undef,
		'MooseX::App' => undef,
		'MooseX::Log::Log4perl' => undef,
		'MooseX::Storage' => undef,
		'Test::Exception' => undef,
		'Test::More' => undef,
		'threads::shared' => undef,
		'threads' => undef,
		'Time::HiRes' => undef,
		'Time::Out' => undef,
	},

	optional => { },
);

$builder->create_build_script();
