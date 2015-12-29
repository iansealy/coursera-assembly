#!/usr/bin/env perl

# PODNAME: string-reconstruction.pl
# ABSTRACT: String Reconstruction

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-12-23

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'string-reconstruction-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( undef, @patterns ) = path($input_file)->lines( { chomp => 1 } );

my @path = eulerian_path( de_bruijn_graph(@patterns) );
## no critic (ProhibitMagicNumbers)
my $text = substr $path[0], 0, -1;
$text .= join q{}, map { substr $_, -1 } @path;
## use critic

printf "%s\n", $text;

sub de_bruijn_graph {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my %graph;

    foreach my $pattern (@patterns) {
        my $prefix = substr $pattern, 0, -1; ## no critic (ProhibitMagicNumbers)
        my $suffix = substr $pattern, 1;
        $graph{$prefix}{$suffix} = 1;
    }

    return \%graph;
}

sub eulerian_path {
    my ($graph) = @_;

    my $node  = start_node($graph);
    my @cycle = ($node);
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

sub start_node {
    my ($graph) = @_;

    # Get node with fewer incoming edges than outgoing edges
    my %diff;
    foreach my $node1 ( keys %{$graph} ) {
        foreach my $node2 ( keys %{ $graph->{$node1} } ) {
            $diff{$node1}++;
            $diff{$node2}--;
        }
    }

    my ($node) = grep { $diff{$_} > 0 } keys %diff;

    return $node;
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

string-reconstruction.pl

String Reconstruction

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the String Reconstruction Problem.

Input: An integer I<k> followed by a list of I<k>-mers I<Patterns>.

Output: A string I<Text> with I<k-mer> composition equal to I<Patterns>. (If
multiple answers exist, you may return any one.)

=head1 EXAMPLES

    perl string-reconstruction.pl

    perl string-reconstruction.pl \
        --input_file string-reconstruction-extra-input.txt

    diff <(perl string-reconstruction.pl) \
        string-reconstruction-sample-output.txt

    diff \
        <(perl string-reconstruction.pl \
            --input_file string-reconstruction-extra-input.txt) \
        string-reconstruction-extra-output.txt

    perl string-reconstruction.pl --input_file dataset_203_6.txt \
        > dataset_203_6_output.txt

=head1 USAGE

    string-reconstruction.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<k> followed by a list of I<k>-mers
I<Patterns>".

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
