# werk

## Build status

[![Build Status](https://travis-ci.org/marghidanu/werk.svg?branch=master)](https://travis-ci.org/marghidanu/werk)

## Description

## Example

```perl
use Werk::Flow;
use Werk::ExecutorFactory;

my $flow = Werk::Flow->new(
	title => '',
    description => '',
);

my $download = Werk::Task::Custom::Download->new(
	id => 'name',
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
	id => 'aggregator_people_address',
    types => [ qw( company address ) ],
);

foreach $type ( qw( person company address ) ) {
	my $ner_task = Werk::Task::Common::NLP::NER->new(
    	id => sprintf( 'ner_%s', $type ),
        type => $type,
	);

	$flow->add_deps( $tokenizer, $ner_task );
    $flow->add_deps( $ner_task, $agg_people_address, $agg_companies_address );
}

my $save = Werk::Task::Common::Common::Save->new(
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
```

We can take a look at the workflow diagram by calling the `draw` method:

```perl
$flow->draw( 'my_flow.svg' );
```

And now assuming we have a list of URLs we can trigger our "werk-flow" on it:

```perl
my @urls = (
  'http://domain.com/docs/1.html',
  'http://domain.com/docs/2.html',
  ...
  'http://domain.com/docs/1000.html',
);

my $executor = Werk::ExecutorFactory->create( 'Parallel' );
$executor->execute( $flow, { url => $_ } )
	foreach( @urls );
```

The execution plan for the workflow above and the **Parallel** executor kinda looks like this:

	

## Concepts

### Task

### Flow

### Executor

### Context

## Example

## Setting up a development environment

```bash
vagrant up
vagrant ssh

sudo su -
cd /vagrant

perl Build.PL
./Build installdeps
./Build
./Build test
```
