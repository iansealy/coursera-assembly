#!/usr/bin/env perl

# PODNAME: overlap-graph.pl
# ABSTRACT: Overlap Graph

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-01

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'overlap-graph-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my (@patterns) = path($input_file)->lines( { chomp => 1 } );

my $graph = overlap_graph(@patterns);
foreach my $pattern1 ( sort keys %{$graph} ) {
    foreach my $pattern2 ( sort keys %{ $graph->{$pattern1} } ) {
        printf "%s -> %s\n", $pattern1, $pattern2;
    }
}

sub overlap_graph {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my %pattern_for;
    foreach my $pattern (@patterns) {
        my $prefix = substr $pattern, 0, -1; ## no critic (ProhibitMagicNumbers)
        push @{ $pattern_for{$prefix} }, $pattern;
    }

    my %graph;
    foreach my $pattern (@patterns) {
        my $suffix = substr $pattern, 1;
        if ( exists $pattern_for{$suffix} ) {
            foreach my $overlap_pattern ( @{ $pattern_for{$suffix} } ) {
                next if $pattern eq $overlap_pattern;
                $graph{$pattern}{$overlap_pattern} = 1;
            }
        }
    }

    return \%graph;
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

overlap-graph.pl

Overlap Graph

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Overlap Graph Problem.

Input: A collection I<Patterns> of I<k>-mers.

Output: The overlap graph I<Overlap>(I<Patterns>), in the form of an adjacency
list. (You may return the edges in any order.)

=head1 EXAMPLES

    perl overlap-graph.pl

    perl overlap-graph.pl --input_file overlap-graph-extra-input.txt

    diff <(perl overlap-graph.pl) overlap-graph-sample-output.txt

    diff \
        <(perl overlap-graph.pl --input_file overlap-graph-extra-input.txt) \
        overlap-graph-extra-output.txt

    perl overlap-graph.pl --input_file dataset_198_9.txt \
        > dataset_198_9_output.txt

=head1 USAGE

    overlap-graph.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A collection I<Patterns> of I<k>-mers".

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
