# werk

## Build status

[![Build Status](https://travis-ci.org/marghidanu/werk.svg?branch=master)](https://travis-ci.org/marghidanu/werk)

## Description

## Example

In the example below we'll take a list of URLs and run it trough our pipeline which will download the document and extract some information out of it. The steps described here DO NOT exist in the current package and are used only to describe the functionality of **Werk**.

```perl
use Werk::Flow;
use Werk::ExecutorFactory;

my $flow = Werk::Flow->new(
	title => 'ExampleWorkflow',
	description => 'A simple crawler and data extraction pipeline',
);

my $download = Werk::Task::Custom::Download->new(
	id => 'download',
	http_timeout => 5,
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
```

We can take a look at the workflow diagram by calling the `draw` method:

```perl
$flow->draw( 'my_flow.svg' );
```
![DAG](https://raw.githubusercontent.com/marghidanu/werk/master/share/images/documentation_dag.svg?sanitize=true)


And now assuming we have a list of URLs we can trigger our "werk-flow" on it:

```perl
my @urls = (
	'http://domain.com/docs/1.html',
	'http://domain.com/docs/2.html',
	...
	'http://domain.com/docs/1000.html',
);

my $executor = Werk::ExecutorFactory->create( 'Parallel', { parallel_tasks => 5 } );
$executor->execute( $flow, { url => $_ } )
	foreach( @urls );
```

The execution plan for the workflow above and the **Parallel** executor kinda looks like this:

![Plan](https://raw.githubusercontent.com/marghidanu/werk/master/share/images/documentation_plan.svg?sanitize=true)

## Concepts

### Task

Smallest unit of work that represents some specific isolated functionality. These guys are the actual workers and the implementation should be very concise.

* Werk::Task::Code

* Werk::Task::Shell

* Werk::Task::Sleep

* Werk::Task::Dummy

### Flow

### Executor

For a given graph the executor determines the order of tasks execution by generating an execution plan. In parallel mode it will try to determine the degree of parallelism if possible.

* Werk::Executor::Sequential

* Werk::Executor::Parallel

### Context

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
## Building it from source

```bash
perl Build.PL
./Build installdeps
./Build manifest
./Build
./Build test
./Build install
```
