#!/usr/bin/env perl

# PODNAME: genome-path-string.pl
# ABSTRACT: String Spelled by a Genome Path

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-11-29

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'genome-path-string-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my (@patterns) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", genome_path_string(@patterns);

sub genome_path_string {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my $text = $patterns[0];
    foreach my $i ( 1 .. scalar @patterns - 1 ) {
        ## no critic (ProhibitMagicNumbers)
        $text .= substr $patterns[$i], -1, 1;
        ## use critic
    }

    return $text;
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

genome-path-string.pl

String Spelled by a Genome Path

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the String Spelled by a Genome Path Problem.

Input: A sequence of I<k>-mers I<Pattern1>, … ,I<Patternn> such that the last
I<k> - 1 symbols of I<Patterni> are equal to the first I<k-1> symbols of
I<Patterni+1> for 1 ≤ I<i> ≤ I<n>-1.

Output: A string I<Text> of length I<k>+I<n>-1 such that the I<i>-th I<k>-mer in
I<Text> is equal to I<Patterni> (for 1 ≤ I<i> ≤ I<n>).

=head1 EXAMPLES

    perl genome-path-string.pl

    perl genome-path-string.pl --input_file genome-path-string-extra-input.txt

    diff <(perl genome-path-string.pl) genome-path-string-sample-output.txt

    diff \
        <(perl genome-path-string.pl \
            --input_file genome-path-string-extra-input.txt) \
        genome-path-string-extra-output.txt

    perl genome-path-string.pl --input_file dataset_198_3.txt \
        > dataset_198_3_output.txt

=head1 USAGE

    genome-path-string.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A sequence of I<k>-mers I<Pattern1>, … ,I<Patternn>
such that the last I<k> - 1 symbols of I<Patterni> are equal to the first I<k-1>
symbols of I<Patterni+1> for 1 ≤ I<i> ≤ I<n>-1".

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
