#!/usr/bin/env perl

# PODNAME: maximal-non-branching-paths.pl
# ABSTRACT: Maximal Non Branching Paths

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-01-03

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'maximal-non-branching-paths-sample-input.txt';
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

my @paths = maximal_non_branching_paths( \%graph );

foreach my $path (@paths) {
    printf "%s\n", join ' -> ', @{$path};
}

sub maximal_non_branching_paths {
    my ($graph) = @_;

    my @paths;    ## no critic (ProhibitReusedNames)

    my @one_in_one_out_nodes = one_in_one_out_nodes($graph);
    my %is_one_in_one_out = map { $_ => 1 } @one_in_one_out_nodes;

    foreach my $node ( sort { $a <=> $b } keys %{$graph} ) {
        next if $is_one_in_one_out{$node};
        foreach my $next_node ( sort { $a <=> $b } keys %{ $graph->{$node} } ) {
            my @path = ( $node, $next_node );
            while ( $is_one_in_one_out{$next_node} ) {
                $next_node = ( keys %{ $graph->{$next_node} } )[0];
                push @path, $next_node;
            }
            push @paths, \@path;
        }
    }

    push @paths, isolated_cycles( $graph, \%is_one_in_one_out, \@paths );

    return @paths;
}

sub one_in_one_out_nodes {
    my ($graph) = @_;

    my %balance;

    foreach my $node1 ( keys %{$graph} ) {
        foreach my $node2 ( keys %{ $graph->{$node1} } ) {
            $balance{$node1}++;
            $balance{$node2}--;
        }
    }

    return grep { $balance{$_} == 0 } keys %balance;
}

sub isolated_cycles {
    my ( $graph, $is_one_in_one_out, $paths ) = @_;

    my %seen;
    foreach my $path ( @{$paths} ) {
        foreach my $node ( @{$path} ) {
            $seen{$node} = 1;
        }
    }

    my @isolated_cycles;

    foreach my $node ( sort { $a <=> $b } keys %{$graph} ) {
        next if $seen{$node};
        next if !$is_one_in_one_out->{$node};
        my @path = ($node);
        $seen{$node} = 1;
        my $next_node = ( keys %{ $graph->{$node} } )[0];
        while ( $is_one_in_one_out->{$next_node} ) {
            push @path, $next_node;
            last if exists $seen{$next_node};
            $seen{$next_node} = 1;
            $next_node = ( keys %{ $graph->{$next_node} } )[0];
        }
        push @isolated_cycles, \@path;
    }

    return @isolated_cycles;
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

maximal-non-branching-paths.pl

Maximal Non Branching Paths

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Maximal Non Branching Paths.

Input: The adjacency list of a graph whose nodes are integers.

Output: The collection of all maximal nonbranching paths in this graph.

=head1 EXAMPLES

    perl maximal-non-branching-paths.pl

    perl maximal-non-branching-paths.pl \
        --input_file maximal-non-branching-paths-extra-input.txt

    diff <(perl maximal-non-branching-paths.pl) \
        maximal-non-branching-paths-sample-output.txt

    diff \
        <(perl maximal-non-branching-paths.pl \
            --input_file maximal-non-branching-paths-extra-input.txt) \
        maximal-non-branching-paths-extra-output.txt

    perl maximal-non-branching-paths.pl --input_file dataset_6207_2.txt \
        > dataset_6207_2_output.txt

=head1 USAGE

    maximal-non-branching-paths.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "The adjacency list of a graph whose nodes are
integers".

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

This software is Copyright (c) 2016 by Ian Sealy.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
