#!/usr/bin/env perl

# PODNAME: string-composition.pl
# ABSTRACT: String Composition

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
my $input_file = 'string-composition-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $k, $text ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join "\n", string_composition( $k, $text );

sub string_composition {
    my ( $k, $text ) = @_;    ## no critic (ProhibitReusedNames)

    my @composition;
    foreach my $i ( 0 .. ( length $text ) - $k ) {
        push @composition, substr $text, $i, $k;
    }

    @composition = sort @composition;
    return @composition;
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

string-composition.pl

String Composition

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the String Composition Problem.

Input: An integer I<k> and a string I<Text>.

Output: I<Compositionk>(I<Text>) (the I<k>-mers can be provided in any order).

=head1 EXAMPLES

    perl string-composition.pl

    perl string-composition.pl --input_file string-composition-extra-input.txt

    diff <(perl string-composition.pl) string-composition-sample-output.txt

    diff \
        <(perl string-composition.pl \
            --input_file string-composition-extra-input.txt) \
        string-composition-extra-output.txt

    perl string-composition.pl --input_file dataset_197_3.txt \
        > dataset_197_3_output.txt

=head1 USAGE

    string-composition.pl
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
