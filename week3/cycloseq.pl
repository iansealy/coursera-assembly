#!/usr/bin/env perl

# PODNAME: cycloseq.pl
# ABSTRACT: Cyclopeptide Sequencing

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

my @AMINO_ACID_MASS =
  qw(57 71 87 97 99 101 103 113 114 115 128 129 131 137 147 156 163 186);

# Default options
my $input_file = 'cycloseq-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($spectrum) = path($input_file)->lines( { chomp => 1 } );
my @spectrum = split /\s+/xms, $spectrum;

my @peptides;
foreach my $peptide ( cyclopeptide_sequencing(@spectrum) ) {
    push @peptides, join q{-}, @{$peptide};
}
printf "%s\n", join q{ }, @peptides;

sub cyclopeptide_sequencing {
    my (@spectrum) = @_;    ## no critic (ProhibitReusedNames)

    my @output;

    my @peptides = ( [] );    ## no critic (ProhibitReusedNames)

    while (@peptides) {
        my @keep_peptides;
        @peptides = expand(@peptides);
        foreach my $peptide (@peptides) {
            if ( mass($peptide) == $spectrum[-1] ) {
                if (
                    spectra_identical(
                        [ cyclic_spectrum($peptide) ], \@spectrum
                    )
                  )
                {
                    push @output, $peptide;
                }
            }
            elsif (
                spectra_consistent( [ linear_spectrum($peptide) ], \@spectrum )
              )
            {
                push @keep_peptides, $peptide;
            }
        }
        @peptides = @keep_peptides;
    }

    return @output;
}

sub expand {
    my (@peptides) = @_;    ## no critic (ProhibitReusedNames)

    my @expanded_peptides;

    foreach my $peptide (@peptides) {
        foreach my $amino_acid (@AMINO_ACID_MASS) {
            push @expanded_peptides, [ @{$peptide}, $amino_acid ];
        }
    }

    return @expanded_peptides;
}

sub mass {
    my ($peptide) = @_;

    my $mass = 0;
    foreach my $amino_acid ( @{$peptide} ) {
        $mass += $amino_acid;
    }

    return $mass;
}

sub cyclic_spectrum {
    my ($peptide) = @_;

    my @prefix_mass = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( 0 .. 17 ) {    ## no critic (ProhibitMagicNumbers)
            if ( $AMINO_ACID_MASS[$j] == $peptide->[$i] ) {
                push @prefix_mass, $prefix_mass[$i] + $AMINO_ACID_MASS[$j];
            }
        }
    }

    my $peptide_mass = $prefix_mass[-1];

    my @cyclic_spectrum = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( $i + 1 .. scalar @{$peptide} ) {
            push @cyclic_spectrum, $prefix_mass[$j] - $prefix_mass[$i];
            if ( $i > 0 && $j < scalar @{$peptide} ) {
                push @cyclic_spectrum, $prefix_mass[-1] - $cyclic_spectrum[-1];
            }
        }
    }

    @cyclic_spectrum = sort { $a <=> $b } @cyclic_spectrum;

    return @cyclic_spectrum;
}

sub linear_spectrum {
    my ($peptide) = @_;

    my @prefix_mass = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( 0 .. 17 ) {    ## no critic (ProhibitMagicNumbers)
            if ( $AMINO_ACID_MASS[$j] == $peptide->[$i] ) {
                push @prefix_mass, $prefix_mass[$i] + $AMINO_ACID_MASS[$j];
            }
        }
    }

    my @linear_spectrum = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( $i + 1 .. scalar @{$peptide} ) {
            push @linear_spectrum, $prefix_mass[$j] - $prefix_mass[$i];
        }
    }

    @linear_spectrum = sort { $a <=> $b } @linear_spectrum;

    return @linear_spectrum;
}

sub spectra_identical {
    my ( $spectrum1, $spectrum2 ) = @_;

    return 0 if scalar @{$spectrum1} != scalar @{$spectrum2};

    foreach my $i ( 0 .. ( scalar @{$spectrum1} ) - 1 ) {
        return 0 if $spectrum1->[$i] != $spectrum2->[$i];
    }

    return 1;
}

sub spectra_consistent {
    my ( $theoretical_spectrum, $expt_spectrum ) = @_;

    my %expected;
    foreach my $amino_acid ( @{$expt_spectrum} ) {
        $expected{$amino_acid}++;
    }

    foreach my $amino_acid ( @{$theoretical_spectrum} ) {
        return 0
          if !exists $expected{$amino_acid} || $expected{$amino_acid} <= 0;
        $expected{$amino_acid}--;
    }

    return 1;
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

cycloseq.pl

Cyclopeptide Sequencing

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Cyclopeptide Sequencing.

Input: I<Spectrum>.

Output: I<Peptides>.

=head1 EXAMPLES

    perl cycloseq.pl

    perl cycloseq.pl --input_file cycloseq-extra-input.txt

    diff <(perl cycloseq.pl) cycloseq-sample-output.txt

    diff <(perl cycloseq.pl --input_file cycloseq-extra-input.txt) \
        cycloseq-extra-output.txt

    perl cycloseq.pl --input_file dataset_100_5.txt > dataset_100_5_output.txt

=head1 USAGE

    cycloseq.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "I<Spectrum>".

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
