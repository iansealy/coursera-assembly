#!/usr/bin/env perl

# PODNAME: string-reconstruction-from-read-pairs.pl
# ABSTRACT: String Reconstruction from Read-Pairs

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-30

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'string-reconstruction-from-read-pairs-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @patterns ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $d ) = split /\s+/xms, $integers;

my @path = eulerian_path( de_bruijn_graph(@patterns) );
printf "%s\n", string_spelled_by_gapped_patterns( \@path, $k, $d );

sub de_bruijn_graph {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my %graph;

    foreach my $pattern (@patterns) {
        $pattern =~ s/\s+//xmsg;
        my $prefix = $pattern;
        $prefix =~ s/.[|]/|/xms;
        $prefix =~ s/.\z//xms;
        my $suffix = $pattern;
        $suffix =~ s/[|]./|/xms;
        $suffix =~ s/\A.//xms;
        $graph{$prefix}{$suffix} = 1;
    }

    return \%graph;
}

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

sub string_spelled_by_gapped_patterns {
    my ( $kdmers, $k, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my @first_patterns;
    my @second_patterns;
    foreach my $kdmer ( @{$kdmers} ) {
        my ( $first_pattern, $second_pattern ) = split /[|]/xms, $kdmer;
        push @first_patterns,  $first_pattern;
        push @second_patterns, $second_pattern;
    }

    my $prefix_string = string_spelled_by_patterns( \@first_patterns,  $k );
    my $suffix_string = string_spelled_by_patterns( \@second_patterns, $k );
    foreach my $i ( $k + $d .. ( length $prefix_string ) - 1 ) {
        if ( ( substr $prefix_string, $i, 1 ) ne substr $suffix_string,
            $i - $k - $d, 1 )
        {
            return q{};
        }
    }

    return $prefix_string . substr $suffix_string, -( $k + $d );
}

sub string_spelled_by_patterns {
    my ( $kmers, $k ) = @_;    ## no critic (ProhibitReusedNames)

    my $string = q{};
    $string .= join q{}, map { substr $_, 0, 1 } @{$kmers};
    $string .= substr $kmers->[-1], 1;

    return $string;
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

string-reconstruction-from-read-pairs.pl

String Reconstruction from Read-Pairs

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the String Reconstruction from Read-Pairs Problem.

Input: Integers I<k> and I<d> followed by a collection of paired I<k>-mers
I<PairedReads>.

Output: A string I<Text> with (I<k>, I<d>)-mer composition equal to
I<PairedReads>.

=head1 EXAMPLES

    perl string-reconstruction-from-read-pairs.pl

    perl string-reconstruction-from-read-pairs.pl \
        --input_file string-reconstruction-from-read-pairs-extra-input.txt

    diff <(perl string-reconstruction-from-read-pairs.pl) \
        string-reconstruction-from-read-pairs-sample-output.txt

    diff \
        <(perl string-reconstruction-from-read-pairs.pl \
            --input_file \
                string-reconstruction-from-read-pairs-extra-input.txt) \
        string-reconstruction-from-read-pairs-extra-output.txt

    perl string-reconstruction-from-read-pairs.pl \
        --input_file dataset_204_14.txt \
        > dataset_204_14_output.txt

=head1 USAGE

    string-reconstruction-from-read-pairs.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<k> and I<d> followed by a collection of
paired I<k>-mers I<PairedReads>".

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
