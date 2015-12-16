#!/usr/bin/env perl

# PODNAME: de-bruijn-graph-from-kmer.pl
# ABSTRACT: DeBruijn Graph from k-mers

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-16

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'de-bruijn-graph-from-kmer-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my (@patterns) = path($input_file)->lines( { chomp => 1 } );

my $graph = de_bruijn_graph(@patterns);

foreach my $prefix ( sort keys %{$graph} ) {
    printf "%s -> %s\n", $prefix, join q{,}, sort @{ $graph->{$prefix} };
}

sub de_bruijn_graph {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my %graph;

    foreach my $pattern (@patterns) {
        my $prefix = substr $pattern, 0, -1; ## no critic (ProhibitMagicNumbers)
        my $suffix = substr $pattern, 1;
        push @{ $graph{$prefix} }, $suffix;
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

de-bruijn-graph-from-kmer.pl

DeBruijn Graph from I<k>-mers

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the DeBruijn Graph from I<k>-mers Problem.

Input: A collection of I<k>-mers I<Patterns>.

Output: The adjacency list of the de Bruijn graph I<DeBruijn>(I<Patterns>).

=head1 EXAMPLES

    perl de-bruijn-graph-from-kmer.pl

    perl de-bruijn-graph-from-kmer.pl \
        --input_file de-bruijn-graph-from-kmer-extra-input.txt

    diff <(perl de-bruijn-graph-from-kmer.pl) \
        de-bruijn-graph-from-kmer-sample-output.txt

    diff \
        <(perl de-bruijn-graph-from-kmer.pl \
            --input_file de-bruijn-graph-from-kmer-extra-input.txt) \
        de-bruijn-graph-from-kmer-extra-output.txt

    perl de-bruijn-graph-from-kmer.pl --input_file dataset_200_7.txt \
        > dataset_200_7_output.txt

=head1 USAGE

    de-bruijn-graph-from-kmer.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A collection of I<k>-mers I<Patterns>".

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
