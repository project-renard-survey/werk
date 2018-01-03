#!/usr/bin/env perl

package CrawlFlow {
	use Moose;

	extends 'Werk::Flow';

	use Mojo::UserAgent;
	use Mojo::ByteStream qw( b );

	use Werk::Task::Code;
	use Werk::Task::Dummy;

	sub BUILD {
		my $self = shift();

		my $download = Werk::Task::Code->new( id => 'download', code => \&download );
		my $content = Werk::Task::Code->new( id => 'content', code => \&content );
		my $sentences = Werk::Task::Code->new( id => 'sentences', code => \&sentences );
		my $people = Werk::Task::Code->new( id => 'people', code => \&people );
		my $times = Werk::Task::Code->new( id => 'times', code => \&times );

		my $save = Werk::Task::Dummy->new( id => 'save' );

		$self->add_deps( $download, $content );
		$self->add_deps( $content, $sentences, $people, $times );
		$self->add_deps_up( $save, $sentences, $people, $times );

		foreach my $task ( $self->get_tasks() ) {
			$task->on( before_task => sub {
					printf( "Starting task %s\n", shift->id() );
				}
			);

			$task->on( after_task => sub {
					printf( "Done with %s\n", shift()->id() );
				}
			);
		}
	}

	sub download {
		my ( $t, $c ) = @_;

		return Mojo::UserAgent->new()
			->get( $c->get_global( 'url' ) )
			->result()
			->body();
	}

	sub content {
		my ( $t, $c ) = @_;

		my $body = b( $c->get_result( 'download' ) )
			->encode();

		return Mojo::UserAgent->new()
			->post( 'http://www.datasciencetoolkit.org/html2story' => $body )
			->result()
			->json( '/story' );
	}

	sub sentences {
		my ( $t, $c ) = @_;

		my $body = b( $c->get_result( 'content' ) )
			->encode();

		return Mojo::UserAgent->new()
			->post( 'http://www.datasciencetoolkit.org/text2sentences' => $body  )
			->result()
			->json( '/sentences' );
	}

	sub people {
		my ( $t, $c ) = @_;

		my $body = b( $c->get_result( 'content' ) )
			->encode();

		return Mojo::UserAgent->new()
			->post( 'http://www.datasciencetoolkit.org/text2people' => $body )
			->result()
			->json();
	}

	sub times {
		my ( $t, $c ) = @_;

		my $body = b( $c->get_result( 'content' ) )
			->encode();

		return Mojo::UserAgent->new()
			->post( 'http://www.datasciencetoolkit.org/text2times' => $body )
			->result()
			->json();
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Time::HiRes qw( time );

	use Werk::ExecutorFactory;

	my @data = <DATA>;
	chomp( @data );
	my @urls = grep { $_ !~ /^#/ }
		grep { $_ } @data;

	my $flow = CrawlFlow->new(
		title => 'CrawlerFlow'
	);

	my $executor = Werk::ExecutorFactory->create( 'Local', { parallel_tasks => 0 } );

	$executor->draw( $flow, 'crawl.plan.svg' );

	foreach my $url ( @urls ) {
		printf( "Processing: %s\n", $url );

		my $start = time();
		$executor->execute( $flow, { url => $url } );
		printf( "Executed in %f seconds.\n", time() - $start );
	}
}

__DATA__

https://www.cpexecutive.com/post/bridge-office-sells-460-ksf-metro-atlanta-complex/
https://www.cpexecutive.com/post/cresa-to-manage-national-united-access-portfolio/
# https://www.cpexecutive.com/post/total-return-ranking/
# https://www.cpexecutive.com/post/development-17/
# https://www.cpexecutive.com/post/industrial-demand-16/
# https://www.cpexecutive.com/post/commercial-and-multifamily-mortgage-flows/
# https://www.cpexecutive.com/post/cap-rates-13/
# https://www.cpexecutive.com/post/employment-picture-18/
# https://www.cpexecutive.com/post/national-absorption/
# https://www.cpexecutive.com/post/national-occupancy/
# https://www.cpexecutive.com/post/sales-volume-cap-rates-2/
# https://www.cpexecutive.com/post/reit-dividend-yields-4/
# https://www.cpexecutive.com/post/top-5-retail-space-sales-3/
# https://www.cpexecutive.com/post/top-5-office-building-sales-3/
# https://www.cpexecutive.com/post/baby-boomers-impact-on-the-apartment-industry/
# https://www.cpexecutive.com/post/market-pulse-for-january-2018/
# https://www.cpexecutive.com/post/top-5-nyc-multifamily-sales-13/
# https://www.cpexecutive.com/post/rent-growth-20/
# https://www.cpexecutive.com/post/apartment-transactions/
