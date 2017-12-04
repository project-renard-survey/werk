#!/usr/bin/env perl

package Werk::Task::Custom::Download {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package Werk::Task::Custom::ContentExtractor {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package Werk::Task::Common::NLP::Tokenizer {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package Werk::Task::Common::NLP::NER {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package Werk::Task::Common::NLP::RelationExtractor {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package Werk::Task::Common::Data::Save {
	use Moose;

	extends 'Werk::Task';

	sub run { }

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use Moose;

	use Werk::Flow;
	use Werk::ExecutorFactory;

	my $flow = Werk::Flow->new(
		title => 'Example workflow',
		description => 'A simple crawler and data extraction pipeline',
	);

	my $download = Werk::Task::Custom::Download->new(
		id => 'download',
		timeout => 5,
		use_robots => 1,
	);

	my $content_extractor = Werk::Task::Custom::ContentExtractor->new(
		id => 'extractor',
		tool => 'Boilerpipe',
		tool_args => {
			strategy => 'ArticleExtractor'
		}
	);
	$flow->add_deps( $download, $content_extractor );

	my $tokenizer = Werk::Task::Common::NLP::Tokenizer->new(
		id => 'tokenizer'
	);
	$flow->add_deps( $content_extractor, $tokenizer );

	my $agg_people_address = Werk::Task::Common::NLP::RelationExtractor->new(
		id => 'aggregator_people_address',
		types => [ qw( person address ) ],
	);

	my $agg_companies_address = Werk::Task::Common::NLP::RelationExtractor->new(
		id => 'aggregator_companies_address',
		types => [ qw( company address ) ],
	);

	foreach my $type ( qw( person company address ) ) {
		my $ner_task = Werk::Task::Common::NLP::NER->new(
			id => sprintf( 'ner_%s', $type ),
			type => $type,
		);

		$flow->add_deps( $tokenizer, $ner_task );
		$flow->add_deps( $ner_task, $agg_people_address, $agg_companies_address );
	}

	my $save = Werk::Task::Common::Data::Save->new(
		id => 'save',
		type => 'MongoDB',
		args => {
			server => 'localhost',
			port => 27017,
			namespace => 'crawler.documents',
		}
	);

	$flow->add_deps( $agg_people_address, $save );
	$flow->add_deps( $agg_companies_address, $save );

	$flow->draw( 'share/images/documentation_dag.svg' );

	Werk::ExecutorFactory->create( 'Parallel' )
		->draw( $flow, 'share/images/documentation_plan.svg' )
}

1;
