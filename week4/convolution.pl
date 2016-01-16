#!/usr/bin/env perl

# PODNAME: convolution.pl
# ABSTRACT: Convolution Cyclopeptide Sequencing

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-01-16

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'convolution-sample-input.txt';
my ( $all, $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $m, $n, $spectrum ) = path($input_file)->lines( { chomp => 1 } );
my @spectrum = sort { $a <=> $b } split /\s+/xms, $spectrum;

if ( !$all ) {
    printf "%s\n", join q{-},
      @{ ( convolution_cyclopeptide_sequencing( $m, $n, @spectrum ) )[0] };
}
else {
    printf "%s\n", join q{ },
      map { join q{-}, @{$_} }
      convolution_cyclopeptide_sequencing( $m, $n, @spectrum );
}

sub convolution_cyclopeptide_sequencing {
    my ( $m, $n, @spectrum ) = @_;    ## no critic (ProhibitReusedNames)

    my @convolution = spectral_convolution(@spectrum);
    my @amino_acid_mass = top_convolution( $m, @convolution );

    my @leaderboard = ( [] );
    my $leader_peptide_score = 0;
    my @leader_peptides;
    while (@leaderboard) {
        my @keep_peptides;
        @leaderboard = expand( \@amino_acid_mass, @leaderboard );
        foreach my $peptide (@leaderboard) {
            if ( mass($peptide) == $spectrum[-1] ) {
                my $peptide_score =
                  cyclic_scoring( \@amino_acid_mass, $peptide, @spectrum );
                if ( $peptide_score > $leader_peptide_score ) {
                    $leader_peptide_score = $peptide_score;
                    @leader_peptides      = ($peptide);
                }
                elsif ( $peptide_score == $leader_peptide_score ) {
                    push @leader_peptides, $peptide;
                }
                push @keep_peptides, $peptide;
            }
            elsif ( mass($peptide) < $spectrum[-1] ) {
                push @keep_peptides, $peptide;
            }
        }
        @leaderboard =
          trim( \@amino_acid_mass, \@keep_peptides, \@spectrum, $n );
    }

    return @leader_peptides;
}

sub spectral_convolution {
    my (@spectrum) = @_;    ## no critic (ProhibitReusedNames)

    my @convolution;

    foreach my $i ( 1 .. ( scalar @spectrum ) - 1 ) {
        foreach my $j ( 0 .. $i - 1 ) {
            next if $spectrum[$i] == $spectrum[$j];
            push @convolution, $spectrum[$i] - $spectrum[$j];
        }
    }

    return @convolution;
}

sub top_convolution {
    my ( $m, @convolution ) = @_;    ## no critic (ProhibitReusedNames)

    my %count;
    foreach my $element (@convolution) {
        ## no critic (ProhibitMagicNumbers)
        next if $element < 57 || $element > 200;
        ## use critic
        $count{$element}++;
    }

    my @amino_acid_mass = keys %count;
    my @counts          = values %count;
    my @idx             = reverse sort { $counts[$a] <=> $counts[$b] }
      ( 0 .. ( scalar @amino_acid_mass ) - 1 );
    @amino_acid_mass = @amino_acid_mass[@idx];
    @counts          = @counts[@idx];

    foreach my $j ( $m .. ( scalar @amino_acid_mass ) - 1 ) {
        if ( $counts[$j] < $counts[ $m - 1 ] ) {
            @amino_acid_mass = @amino_acid_mass[ 0 .. $j - 1 ];
            return @amino_acid_mass;
        }
    }

    return @amino_acid_mass;
}

sub expand {
    my ( $amino_acid_mass, @peptides ) = @_;

    my @expanded_peptides;

    foreach my $peptide (@peptides) {
        foreach my $amino_acid ( @{$amino_acid_mass} ) {
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
    ## no critic (ProhibitReusedNames)
    my ( $amino_acid_mass, $leaderboard, $spectrum, $n ) = @_;
    ## use critic

    my @linear_scores =
      map { linear_scoring( $amino_acid_mass, $_, @{$spectrum} ) }
      @{$leaderboard};
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
    ## no critic (ProhibitReusedNames)
    my ( $amino_acid_mass, $peptide, @spectrum ) = @_;
    ## use critic

    my @theoretical_spectrum = linear_spectrum( $amino_acid_mass, $peptide );

    return score_spectra( \@spectrum, \@theoretical_spectrum );
}

sub linear_spectrum {
    my ( $amino_acid_mass, $peptide ) = @_;

    my @prefix_mass = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( 0 .. ( scalar @{$amino_acid_mass} ) - 1 ) {
            if ( $amino_acid_mass->[$j] == $peptide->[$i] ) {
                push @prefix_mass, $prefix_mass[$i] + $amino_acid_mass->[$j];
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

sub cyclic_scoring {
    ## no critic (ProhibitReusedNames)
    my ( $amino_acid_mass, $peptide, @spectrum ) = @_;
    ## use critic

    my @theoretical_spectrum = cyclic_spectrum( $amino_acid_mass, $peptide );

    return score_spectra( \@spectrum, \@theoretical_spectrum );
}

sub cyclic_spectrum {
    my ( $amino_acid_mass, $peptide ) = @_;

    my @prefix_mass = (0);

    foreach my $i ( 0 .. ( scalar @{$peptide} ) - 1 ) {
        foreach my $j ( 0 .. ( scalar @{$amino_acid_mass} ) - 1 ) {
            if ( $amino_acid_mass->[$j] == $peptide->[$i] ) {
                push @prefix_mass, $prefix_mass[$i] + $amino_acid_mass->[$j];
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
        'all'          => \$all,
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

convolution.pl

Convolution Cyclopeptide Sequencing

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Convolution Cyclopeptide Sequencing.

Input: An integer I<N> and a collection of integers I<Spectrum>.

Output: I<LeaderPeptide> after running
I<LeaderboardCyclopeptideSequencing>(I<Spectrum>, I<N>).

=head1 EXAMPLES

    perl convolution.pl

    perl convolution.pl --input_file convolution-extra-input.txt

    diff <(perl convolution.pl) convolution-sample-output.txt

    diff <(perl convolution.pl --input_file convolution-extra-input.txt) \
        convolution-extra-output.txt

    perl convolution.pl --input_file dataset_104_7.txt \
        > dataset_104_7_output.txt

    perl convolution.pl --all --input_file dataset_104_8.txt \
        > dataset_104_8_output.txt

=head1 USAGE

    convolution.pl
        [--input_file FILE]
        [--all]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<N> and a collection of integers
I<Spectrum>".

=item B<--all>

Return all linear peptides with maximum score.

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
