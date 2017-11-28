#!/usr/bin/env perl

use strict;
use warnings;

use Graph;
use GraphViz2;

sub print_topo_sort {
    my %deps = @_;

    my %ba;
    while ( my ( $before, $afters_aref ) = each %deps ) {
        for my $after ( @{ $afters_aref } ) {
            $ba{$before}{$after} = 1 if $before ne $after;
            $ba{$after} ||= {};
        }
    }

    while ( my @afters = sort grep { ! %{ $ba{$_} } } keys %ba ) {
        print "@afters\n";
        delete @ba{@afters};
        delete @{$_}{@afters} for values %ba;
    }

    print !!%ba ? "Cycle found! ". join( ' ', sort keys %ba ). "\n" : "---\n";
}

sub sort2 {
	my $graph = shift();

	my %ba;
	foreach my $edge ( $graph->edges() ) {
		my ( $from, $to ) = @{ $edge };

		$ba{ $from }{ $to } = 1
			unless( $from eq $to );

		$ba{ $to } ||= {};
	}

	use Data::Dumper;
	warn( Dumper( [grep { ! %{ $ba{ $_ } } } keys( %ba )] ) );

	my @result = ();
	while( my @a = sort grep { ! %{ $ba{ $_ } } } keys( %ba ) ) {
		push( @result, \@a );
		delete( @ba{@a} );
		delete( @{$_}{ @a } )
			foreach( values %ba );
	}

	use Data::Dumper;
	warn( Dumper( [reverse @result] ) );
}

sub create_graph {
	my %deps = @_;

	my $graph = Graph->new( directed => 1 );

	while( my ( $from, $to ) = each( %deps ) ) {
		$graph->add_edge( $from, $_ )
			foreach( @{ $to } );
	}

	return $graph;
}

sub draw_graph {
	# my $graph = shift();
	my ( $graph, $file ) = @_;

	my $gv = GraphViz2->new( global => { directed => 1 } );

	$gv->add_node( name => $_, label => $_ )
		foreach( $graph->vertices() );

	$gv->add_edge( from => $_->[0], to => $_->[1] )
		foreach( $graph->edges() );

	$gv->run( output_file => $file );
}

my %deps = (
	load => [ qw( enrich reduce other ) ],
	reduce => [ 'test' ],
	enrich => [ 'save' ],
	test => [ 'save', 'nothing' ],
);

my $graph = create_graph( %deps );
sort2( $graph );
draw_graph( $graph, 'topo_sort.svg' );

#print_topo_sort(%deps);

# push @{ $deps{'dw01'} }, 'dw04'; # Add unresolvable dependency
# print_topo_sort(%deps);
