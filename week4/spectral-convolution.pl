#!/usr/bin/env perl

# PODNAME: spectral-convolution.pl
# ABSTRACT: Spectral Convolution

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
my $input_file = 'spectral-convolution-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($spectrum) = path($input_file)->lines( { chomp => 1 } );
my @spectrum = split /\s+/xms, $spectrum;

printf "%s\n", join q{ }, spectral_convolution(@spectrum);

sub spectral_convolution {
    my (@spectrum) = @_;    ## no critic (ProhibitReusedNames)

    @spectrum = sort { $a <=> $b } @spectrum;

    my @convolution;

    foreach my $i ( 1 .. ( scalar @spectrum ) - 1 ) {
        foreach my $j ( 0 .. $i - 1 ) {
            next if $spectrum[$i] == $spectrum[$j];
            push @convolution, $spectrum[$i] - $spectrum[$j];
        }
    }

    return @convolution;
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

spectral-convolution.pl

Spectral Convolution

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Spectral Convolution Problem.

Input: A collection of integers I<Spectrum>.

Output: The list of elements in the convolution of I<Spectrum>. If an element
has multiplicity I<k>, it should appear exactly I<k> times; you may return the
elements in any order.

=head1 EXAMPLES

    perl spectral-convolution.pl

    perl spectral-convolution.pl \
        --input_file spectral-convolution-extra-input.txt

    diff <(perl spectral-convolution.pl) spectral-convolution-sample-output.txt

    diff <(perl spectral-convolution.pl \
        --input_file spectral-convolution-extra-input.txt) \
        spectral-convolution-extra-output.txt

    perl spectral-convolution.pl --input_file dataset_104_4.txt \
        > dataset_104_4_output.txt

=head1 USAGE

    spectral-convolution.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A collection of integers I<Spectrum>".

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
