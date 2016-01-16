#!/usr/bin/env perl

# PODNAME: leaderboard.pl
# ABSTRACT: Leaderboard Cyclopeptide Sequencing

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-01-15

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
my $input_file = 'leaderboard-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $n, $spectrum ) = path($input_file)->lines( { chomp => 1 } );
my @spectrum = split /\s+/xms, $spectrum;

printf "%s\n", join q{-}, leaderboard_cyclopeptide_sequencing( $n, @spectrum );

sub leaderboard_cyclopeptide_sequencing {
    my ( $n, @spectrum ) = @_;    ## no critic (ProhibitReusedNames)

    my @leaderboard = ( [] );
    my $leader_peptide = [];
    while (@leaderboard) {
        my @keep_peptides;
        @leaderboard = expand(@leaderboard);
        foreach my $peptide (@leaderboard) {
            if ( mass($peptide) == $spectrum[-1] ) {
                if ( linear_scoring( $peptide, @spectrum ) >
                    linear_scoring( $leader_peptide, @spectrum ) )
                {
                    $leader_peptide = $peptide;
                }
                push @keep_peptides, $peptide;
            }
            elsif ( mass($peptide) < $spectrum[-1] ) {
                push @keep_peptides, $peptide;
            }
        }
        @leaderboard = trim( \@keep_peptides, \@spectrum, $n );
    }

    return @{$leader_peptide};
}

sub expand {
    my (@peptides) = @_;

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

sub trim {
    my ( $leaderboard, $spectrum, $n ) = @_;  ## no critic (ProhibitReusedNames)

    my @linear_scores =
      map { linear_scoring( $_, @{$spectrum} ) } @{$leaderboard};
    my @idx = reverse sort { $linear_scores[$a] <=> $linear_scores[$b] }
      ( 0 .. ( scalar @{$leaderboard} ) - 1 );
    @{$leaderboard} = @{$leaderboard}[@idx];
    @linear_scores = @linear_scores[@idx];

    foreach my $j ( $n .. ( scalar @{$leaderboard} ) - 1 ) {
        if ( $linear_scores[$j] < $linear_scores[ $n - 1 ] ) {
            @{$leaderboard} = @{$leaderboard}[ 0 .. $j - 1 ];
            return @{$leaderboard};
        }
    }

    return @{$leaderboard};
}

sub linear_scoring {
    my ( $peptide, @spectrum ) = @_;    ## no critic (ProhibitReusedNames)

    my @theoretical_spectrum = linear_spectrum($peptide);

    return score_spectra( \@spectrum, \@theoretical_spectrum );
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

sub score_spectra {
    my ( $spectrum1, $spectrum2 ) = @_;

    my $score = 0;

    my $i1 = 0;
    my $i2 = 0;
    while ( $i1 < scalar @{$spectrum1} && $i2 < scalar @{$spectrum2} ) {
        if ( $spectrum1->[$i1] < $spectrum2->[$i2] ) {
            $i1++;
        }
        elsif ( $spectrum1->[$i1] > $spectrum2->[$i2] ) {
            $i2++;
        }
        else {
            $score++;
            $i1++;
            $i2++;
        }
    }

    return $score;
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

leaderboard.pl

Leaderboard Cyclopeptide Sequencing

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Leaderboard Cyclopeptide Sequencing.

Input: An integer I<N> and a collection of integers I<Spectrum>.

Output: I<LeaderPeptide> after running
I<LeaderboardCyclopeptideSequencing>(I<Spectrum>, I<N>).

=head1 EXAMPLES

    perl leaderboard.pl

    perl leaderboard.pl --input_file leaderboard-extra-input.txt

    diff <(perl leaderboard.pl) leaderboard-sample-output.txt

    diff <(perl leaderboard.pl --input_file leaderboard-extra-input.txt) \
        leaderboard-extra-output.txt

    perl leaderboard.pl --input_file dataset_102_7.txt \
        > dataset_102_7_output.txt

=head1 USAGE

    leaderboard.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<N> and a collection of integers
I<Spectrum>".

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
