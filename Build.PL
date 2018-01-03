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
		'Class::Load' => undef,
		'Data::PathSimple' => undef,
		'Data::UUID' => undef,
		'File::Slurp' => undef,
		'File::Temp' => undef,
		'Graph' => undef,
		'GraphViz2' => undef,
		'JSON::XS' => undef,
		'Moose' => undef,
		'MooseX::AbstractFactory' => undef,
		'MooseX::AbstractMethod' => undef,
		'Sub::Retry' => undef,
		'Sys::Info::Base' => undef,
		'Sys::Info::Driver::Linux' => undef,
		'Test::Deep' => undef,
		'Test::Exception' => undef,
		'Test::More' => undef,
		'Test::Pod::Coverage' => undef,
		'Text::Template' => undef,
		'threads::shared' => undef,
		'threads' => undef,
		'Throwable' => undef,
		'Time::HiRes' => undef,
		'Time::Out' => undef,
	},

	optional => { },
);

$builder->create_build_script();
