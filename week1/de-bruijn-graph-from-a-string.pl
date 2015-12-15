#!/usr/bin/env perl

# PODNAME: de-bruijn-graph-from-a-string.pl
# ABSTRACT: De Bruijn Graph from a String

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-15

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'de-bruijn-graph-from-a-string-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $k, $text ) = path($input_file)->lines( { chomp => 1 } );

my $graph = de_bruijn_graph( $k, $text );

foreach my $prefix ( sort keys %{$graph} ) {
    printf "%s -> %s\n", $prefix, join q{,}, sort @{ $graph->{$prefix} };
}

sub de_bruijn_graph {
    my ( $k, $text ) = @_;    ## no critic (ProhibitReusedNames)

    my %graph;

    foreach my $i ( 0 .. ( length $text ) - $k ) {
        my $kmer = substr $text, $i, $k;
        my $prefix = substr $kmer, 0, -1;    ## no critic (ProhibitMagicNumbers)
        my $suffix = substr $kmer, 1;
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

de-bruijn-graph-from-a-string.pl

De Bruijn Graph from a String

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the De Bruijn Graph from a String Problem.

Input: An integer I<k> and a string I<Text>.

Output: I<DeBruijnk>(I<Text>), in the form of an adjacency list.

=head1 EXAMPLES

    perl de-bruijn-graph-from-a-string.pl

    perl de-bruijn-graph-from-a-string.pl \
        --input_file de-bruijn-graph-from-a-string-extra-input.txt

    diff <(perl de-bruijn-graph-from-a-string.pl) \
        de-bruijn-graph-from-a-string-sample-output.txt

    diff \
        <(perl de-bruijn-graph-from-a-string.pl \
            --input_file de-bruijn-graph-from-a-string-extra-input.txt) \
        de-bruijn-graph-from-a-string-extra-output.txt

    perl de-bruijn-graph-from-a-string.pl --input_file dataset_199_6.txt \
        > dataset_199_6_output.txt

=head1 USAGE

    de-bruijn-graph-from-a-string.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<k> and a string I<Text>".

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
