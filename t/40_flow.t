#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use JSON::XS qw( decode_json );

require_ok( 'Werk::Flow' );
can_ok( 'Werk::Flow', qw( from_json ) );

my $json = join( '', <DATA> );
my $data = decode_json( $json );
my $flow = Werk::Flow->from_json( $json );

isa_ok( $flow, 'Werk::Flow' );
can_ok( $flow, qw( get_tasks ) );

my @tasks = $flow->get_tasks();

eq_deeply(
	[ sort( map { $_->id() } @tasks ) ],
	[ sort( keys( %{ $data->{tasks} } ) ) ],
);

isa_ok( $_, 'Werk::Task::Dummy' )
	foreach( @tasks );

my $deps = {};
push( @{ $deps->{ $_->[0]->id() } }, $_->[1]->id() )
	foreach ( $flow->get_deps() );

eq_deeply( $deps, $data->{deps} );

# $flow->draw( 'test.svg' );

done_testing();

__DATA__

{
	"meta" : {
		"title" : "SampleWorkflow",
		"description": "A sample workflow for deserilization"
	},

	"tasks" : {
		"download" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "File downloader"
			}
		},

		"extractor" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" :  "Content extractor"
			}
		},

		"tokenizer" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Word tokenizer"
			}
		},

		"ner_person" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Name extractor"
			}
		},

		"ner_company" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Company extractor"
			}
		},

		"ner_address" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Title extractor"
			}
		},

		"re_person_address" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Person-Address relation extractor"
			}
		},

		"re_company_address" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Company-Address relation extractor"
			}
		},

		"save" : {
			"class" : "Werk::Task::Dummy",
			"args" : {
				"title" : "Persist in database"
			}
		}
	},

	"deps" : {
		"download" : [ "extractor" ],
		"extractor" : [ "tokenizer" ],
		"tokenizer" : [ "ner_address", "ner_company", "ner_person" ],
		"ner_person" : [ "re_person_address" ],
		"ner_address" : [ "re_company_address", "re_person_address" ],
		"ner_company" : [ "re_company_address" ],
		"re_person_address" : [ "save" ],
		"re_company_address" : [ "save" ]
	}
}
