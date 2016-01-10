#!/usr/bin/env perl

# PODNAME: theoretical-spectrum.pl
# ABSTRACT: Generating Theoretical Spectrum

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

my @AMINO_ACID = qw(G A S P V T C I L N D K Q E M H F R Y W);
my @AMINO_ACID_MASS =
  qw(57 71 87 97 99 101 103 113 113 114 115 128 128 129 131 137 147 156 163 186);

# Default options
my $input_file = 'theoretical-spectrum-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($peptide) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, theoretical_spectrum($peptide);

sub theoretical_spectrum {
    my ($peptide) = @_;    ## no critic (ProhibitReusedNames)

    return cyclic_spectrum($peptide);
}

sub cyclic_spectrum {
    my ($peptide) = @_;    ## no critic (ProhibitReusedNames)

    my @prefix_mass = (0);

    foreach my $i ( 0 .. ( length $peptide ) - 1 ) {
        foreach my $j ( 0 .. 19 ) {    ## no critic (ProhibitMagicNumbers)
            if ( $AMINO_ACID[$j] eq substr $peptide, $i, 1 ) {
                push @prefix_mass, $prefix_mass[$i] + $AMINO_ACID_MASS[$j];
            }
        }
    }

    my $peptide_mass = $prefix_mass[-1];

    my @cyclic_spectrum = (0);

    foreach my $i ( 0 .. ( length $peptide ) - 1 ) {
        foreach my $j ( $i + 1 .. length $peptide ) {
            push @cyclic_spectrum, $prefix_mass[$j] - $prefix_mass[$i];
            if ( $i > 0 && $j < length $peptide ) {
                push @cyclic_spectrum, $prefix_mass[-1] - $cyclic_spectrum[-1];
            }
        }
    }

    @cyclic_spectrum = sort { $a <=> $b } @cyclic_spectrum;

    return @cyclic_spectrum;
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

theoretical-spectrum.pl

Generating Theoretical Spectrum

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Generating Theoretical Spectrum Problem.

Input: An amino acid string I<Peptide>.

Output: I<Cyclospectrum>(I<Peptide>).

=head1 EXAMPLES

    perl theoretical-spectrum.pl

    perl theoretical-spectrum.pl \
        --input_file theoretical-spectrum-extra-input.txt

    diff <(perl theoretical-spectrum.pl) theoretical-spectrum-sample-output.txt

    diff <(perl theoretical-spectrum.pl \
        --input_file theoretical-spectrum-extra-input.txt) \
        theoretical-spectrum-extra-output.txt

    perl theoretical-spectrum.pl --input_file dataset_98_4.txt \
        > dataset_98_4_output.txt

=head1 USAGE

    theoretical-spectrum.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An amino acid string I<Peptide>".

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
