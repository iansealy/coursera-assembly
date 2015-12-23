#!/usr/bin/env perl

# PODNAME: eulerian-path.pl
# ABSTRACT: Eulerian Path

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-23

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'eulerian-path-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my (@list) = path($input_file)->lines( { chomp => 1 } );
my %graph;
foreach my $line (@list) {
    my ( $node1, $node2s ) = split /\s->\s/xms, $line;
    foreach my $node2 ( split /,/xms, $node2s ) {
        $graph{$node1}{$node2} = 1;
    }
}

printf "%s\n", join '->', eulerian_path( \%graph );

sub eulerian_path {
    my ($graph) = @_;

    my $node  = start_node($graph);
    my @cycle = ($node);
    my $pos   = 0;
    while ( keys %{$graph} ) {
        while ( exists $graph->{$node} ) {
            my $next_node = ( keys %{ $graph->{$node} } )[0];   # Arbitrary node
            delete $graph->{$node}{$next_node};
            if ( !keys %{ $graph->{$node} } ) {
                delete $graph->{$node};
            }
            splice @cycle, ++$pos, 0, $next_node;
            $node = $next_node;
        }
        ( $node, $pos ) = new_start_node( \@cycle, $graph );
    }

    return @cycle;
}

sub start_node {
    my ($graph) = @_;

    # Get node with fewer incoming edges than outgoing edges
    my %diff;
    foreach my $node1 ( keys %{$graph} ) {
        foreach my $node2 ( keys %{ $graph->{$node1} } ) {
            $diff{$node1}++;
            $diff{$node2}--;
        }
    }

    my ($node) = grep { $diff{$_} > 0 } keys %diff;

    return $node;
}

sub new_start_node {
    my ( $cycle, $graph ) = @_;

    my $pos = 0;
    foreach my $node ( @{$cycle} ) {
        return $node, $pos if exists $graph->{$node};
        $pos++;
    }

    return;
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'input_file=s' => \$input_file,
        'debug'        => \$debug,
        'help'         => \$help,
        'man'          => \$man,
    ) or pod2usage(2);

    # Documentation
    if ($help) {
        pod2usage(1);
    }
    elsif ($man) {
        pod2usage( -verbose => 2 );
    }

    return;
}

__END__
=pod

=encoding UTF-8

=head1 NAME

eulerian-path.pl

Eulerian Path

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Eulerian Path Problem.

Input: The adjacency list of a directed graph that has an Eulerian path.

Output: An Eulerian path in this graph.

=head1 EXAMPLES

    perl eulerian-path.pl

    perl eulerian-path.pl --input_file eulerian-path-extra-input.txt

    diff <(perl eulerian-path.pl) eulerian-path-sample-output.txt

    diff \
        <(perl eulerian-path.pl --input_file eulerian-path-extra-input.txt) \
        eulerian-path-extra-output.txt

    perl eulerian-path.pl --input_file dataset_203_5.txt \
        > dataset_203_5_output.txt

=head1 USAGE

    eulerian-path.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "The adjacency list of a directed graph that has an
Eulerian path".

=item B<--debug>

Print debugging information.

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print this script's manual page and exit.

=back

=head1 DEPENDENCIES

None

=head1 AUTHOR

=over 4

=item *

Ian Sealy

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Ian Sealy.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
