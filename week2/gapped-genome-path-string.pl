#!/usr/bin/env perl

# PODNAME: gapped-genome-path-string.pl
# ABSTRACT: String Spelled By Gapped Patterns

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-30

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'gapped-genome-path-string-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @kdmers ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $d ) = split /\s+/xms, $integers;

printf "%s\n", string_spelled_by_gapped_patterns( \@kdmers, $k, $d );

sub string_spelled_by_gapped_patterns {
    my ( $kdmers, $k, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my @first_patterns;
    my @second_patterns;
    foreach my $kdmer ( @{$kdmers} ) {
        my ( $first_pattern, $second_pattern ) = split /[|]/xms, $kdmer;
        push @first_patterns,  $first_pattern;
        push @second_patterns, $second_pattern;
    }

    my $prefix_string = string_spelled_by_patterns( \@first_patterns,  $k );
    my $suffix_string = string_spelled_by_patterns( \@second_patterns, $k );
    foreach my $i ( $k + $d .. ( length $prefix_string ) - 1 ) {
        if ( ( substr $prefix_string, $i, 1 ) ne substr $suffix_string,
            $i - $k - $d, 1 )
        {
            return q{};
        }
    }

    return $prefix_string . substr $suffix_string, -( $k + $d );
}

sub string_spelled_by_patterns {
    my ( $kmers, $k ) = @_;    ## no critic (ProhibitReusedNames)

    my $string = q{};
    $string .= join q{}, map { substr $_, 0, 1 } @{$kmers};
    $string .= substr $kmers->[-1], 1;

    return $string;
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

gapped-genome-path-string.pl

String Spelled By Gapped Patterns

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements String Spelled By Gapped Patterns.

Input: Integers I<k> and I<d> followed by a sequence of (I<k>, I<d>)-mers
(I<a1>|I<b1>), … , (I<an>|I<bn>) such that I<Suffix>(I<ai>|I<bi>) =
I<Prefix>(I<ai+1>|I<bi+1>) for 1 ≤ I<i> ≤ I<n>-1.

Output: A string I<Text> of length I<k> + I<d> + I<k> + I<n> - 1 such that the
I<i>-th (I<k>, I<d>)-mer in I<Text> is equal to (I<ai>|I<bi>)  for 1 ≤ I<i> ≤ n
(if such a string exists).

=head1 EXAMPLES

    perl gapped-genome-path-string.pl

    perl gapped-genome-path-string.pl \
        --input_file gapped-genome-path-string-extra-input.txt

    diff <(perl gapped-genome-path-string.pl) \
        gapped-genome-path-string-sample-output.txt

    diff <(perl gapped-genome-path-string.pl \
        --input_file gapped-genome-path-string-extra-input.txt) \
        gapped-genome-path-string-extra-output.txt

    perl gapped-genome-path-string.pl --input_file dataset_6206_7.txt \
        > dataset_6206_7_output.txt

=head1 USAGE

    gapped-genome-path-string.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<k> and I<d> followed by a sequence of
(I<k>, I<d>)-mers (I<a1>|I<b1>), … , (I<an>|I<bn>) such that
I<Suffix>(I<ai>|I<bi>) = I<Prefix>(I<ai+1>|I<bi+1>) for 1 ≤ I<i> ≤ I<n>-1".

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
