#!/usr/bin/env perl

# PODNAME: counting-peptides.pl
# ABSTRACT: Counting Peptides with Given Mass

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
my $input_file = 'counting-peptides-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($m) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", counting_peptides($m);

sub counting_peptides {
    my ($target_mass) = @_;

    my %peptide_count = ( 0 => 1, );

    foreach my $peptide_mass ( $AMINO_ACID_MASS[0] .. $target_mass ) {
        foreach my $amino_acid_mass (@AMINO_ACID_MASS) {
            if ( exists $peptide_count{ $peptide_mass - $amino_acid_mass } ) {
                $peptide_count{$peptide_mass} =
                  $peptide_count{ $peptide_mass - $amino_acid_mass } +
                  ( $peptide_count{$peptide_mass} || 0 );
            }
        }
    }

    return $peptide_count{$target_mass};
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

counting-peptides.pl

Counting Peptides with Given Mass

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Counting Peptides with Given Mass Problem.

Input: An integer I<m>.

Output: The number of linear peptides having integer mass I<m>.

=head1 EXAMPLES

    perl counting-peptides.pl

    perl counting-peptides.pl \
        --input_file counting-peptides-extra-input.txt

    diff <(perl counting-peptides.pl) counting-peptides-sample-output.txt

    diff <(perl counting-peptides.pl \
        --input_file counting-peptides-extra-input.txt) \
        counting-peptides-extra-output.txt

    perl counting-peptides.pl --input_file dataset_99_2.txt \
        > dataset_99_2_output.txt

=head1 USAGE

    counting-peptides.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<m>".

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
