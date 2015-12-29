#!/usr/bin/env perl

# PODNAME: uni-str.pl
# ABSTRACT: k-Universal Circular String

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-29

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'uni-str-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($k) = path($input_file)->lines( { chomp => 1 } );

my @cycle = eulerian_cycle( de_bruijn_graph( binary_strings($k) ) );
## no critic (ProhibitMagicNumbers)
pop @cycle;
my $string = q{};
$string .= join q{}, map { substr $_, -1 } @cycle;
## use critic

printf "%s\n", $string;

sub binary_strings {
    my ($k) = @_;    ## no critic (ProhibitReusedNames)

    my @strings = qw(0 1);

    foreach ( 2 .. $k ) {
        my @new_strings;
        foreach my $string (@strings) {
            foreach my $bit (qw(0 1)) {
                push @new_strings, $string . $bit;
            }
        }
        @strings = @new_strings;
    }

    return @strings;
}

sub de_bruijn_graph {
    my (@patterns) = @_;

    my %graph;

    foreach my $pattern (@patterns) {
        my $prefix = substr $pattern, 0, -1; ## no critic (ProhibitMagicNumbers)
        my $suffix = substr $pattern, 1;
        $graph{$prefix}{$suffix} = 1;
    }

    return \%graph;
}

sub eulerian_cycle {
    my ($graph) = @_;

    my $node  = ( keys %{$graph} )[0];       # Arbitrary start
    my @cycle = ($node);                     ## no critic (ProhibitReusedNames)
    my $pos   = 0;
    while ( keys %{$graph} ) {
        while ( exists $graph->{$node} ) {
            my $next_node = ( keys %{ $graph->{$node} } )[0];   # Arbitrary node
            delete $graph->{$node}{$next_node};
            if ( !keys %{ $graph->{$node} } ) {
                delete $graph->{$node};
            }
            splice @cycle, ++$pos, 0, $next_node;
            $node = $next_node;
        }
        ( $node, $pos ) = new_start_node( \@cycle, $graph );
    }

    return @cycle;
}

sub new_start_node {
    my ( $cycle, $graph ) = @_;

    my $pos = 0;
    foreach my $node ( @{$cycle} ) {
        return $node, $pos if exists $graph->{$node};
        $pos++;
    }

    return;
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

uni-str.pl

k-Universal Circular String

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the k-Universal Circular String Problem.

Input: An integer I<k>.

Output: A k-universal circular string.

=head1 EXAMPLES

    perl uni-str.pl

    perl uni-str.pl --input_file uni-str-extra-input.txt

    diff <(perl uni-str.pl) uni-str-sample-output.txt

    diff <(perl uni-str.pl --input_file uni-str-extra-input.txt) \
        uni-str-extra-output.txt

    perl uni-str.pl --input_file dataset_203_10.txt > dataset_203_10_output.txt

=head1 USAGE

    uni-str.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<k>".

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
