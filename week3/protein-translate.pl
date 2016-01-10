#!/usr/bin/env perl

# PODNAME: protein-translate.pl
# ABSTRACT: Protein Translation

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-01-10

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

my %AMINO_ACID_FOR = (
    AAA => q{K},
    AAC => q{N},
    AAG => q{K},
    AAU => q{N},
    ACA => q{T},
    ACC => q{T},
    ACG => q{T},
    ACU => q{T},
    AGA => q{R},
    AGC => q{S},
    AGG => q{R},
    AGU => q{S},
    AUA => q{I},
    AUC => q{I},
    AUG => q{M},
    AUU => q{I},
    CAA => q{Q},
    CAC => q{H},
    CAG => q{Q},
    CAU => q{H},
    CCA => q{P},
    CCC => q{P},
    CCG => q{P},
    CCU => q{P},
    CGA => q{R},
    CGC => q{R},
    CGG => q{R},
    CGU => q{R},
    CUA => q{L},
    CUC => q{L},
    CUG => q{L},
    CUU => q{L},
    GAA => q{E},
    GAC => q{D},
    GAG => q{E},
    GAU => q{D},
    GCA => q{A},
    GCC => q{A},
    GCG => q{A},
    GCU => q{A},
    GGA => q{G},
    GGC => q{G},
    GGG => q{G},
    GGU => q{G},
    GUA => q{V},
    GUC => q{V},
    GUG => q{V},
    GUU => q{V},
    UAA => q{},
    UAC => q{Y},
    UAG => q{},
    UAU => q{Y},
    UCA => q{S},
    UCC => q{S},
    UCG => q{S},
    UCU => q{S},
    UGA => q{},
    UGC => q{C},
    UGG => q{W},
    UGU => q{C},
    UUA => q{L},
    UUC => q{F},
    UUG => q{L},
    UUU => q{F},
);

# Default options
my $input_file = 'protein-translate-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($pattern) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", protein_translation($pattern);

sub protein_translation {
    my ($pattern) = @_;    ## no critic (ProhibitReusedNames)

    my $peptide = q{};

    while ($pattern) {
        ## no critic (ProhibitMagicNumbers)
        $peptide .= $AMINO_ACID_FOR{ substr $pattern, 0, 3, q{} };
        ## use critic
    }

    return $peptide;
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

protein-translate.pl

Protein Translation

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Protein Translation Problem.

Input: An RNA string I<Pattern> and the array I<GeneticCode>.

Output: The translation of I<Pattern> into an amino acid string I<Peptide>.

=head1 EXAMPLES

    perl protein-translate.pl

    perl protein-translate.pl --input_file protein-translate-extra-input.txt

    diff <(perl protein-translate.pl) protein-translate-sample-output.txt

    diff <(perl protein-translate.pl \
        --input_file protein-translate-extra-input.txt) \
        protein-translate-extra-output.txt

    perl protein-translate.pl --input_file dataset_96_5.txt \
        > dataset_96_5_output.txt

=head1 USAGE

    protein-translate.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An RNA string I<Pattern> and the array
I<GeneticCode>".

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
