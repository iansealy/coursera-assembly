#!/usr/bin/env perl

# PODNAME: contig-generation.pl
# ABSTRACT: Contig Generation

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-01-03

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'contig-generation-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my (@patterns) = path($input_file)->lines( { chomp => 1 } );

my @paths = contig_generation( de_bruijn_graph(@patterns) );

my @contigs;
foreach my $path (@paths) {
    ## no critic (ProhibitMagicNumbers)
    my $text = substr $path->[0], 0, -1;
    $text .= join q{}, map { substr $_, -1 } @{$path};
    ## use critic
    push @contigs, $text;
}

printf "%s\n", join "\n", sort @contigs;

sub de_bruijn_graph {
    my (@patterns) = @_;    ## no critic (ProhibitReusedNames)

    my %graph;

    foreach my $pattern (@patterns) {
        my $prefix = substr $pattern, 0, -1; ## no critic (ProhibitMagicNumbers)
        my $suffix = substr $pattern, 1;
        $graph{$prefix}{$suffix}++;
    }

    return \%graph;
}

sub contig_generation {
    my ($graph) = @_;

    my %in;
    my %out;
    foreach my $node1 ( keys %{$graph} ) {
        foreach my $node2 ( keys %{ $graph->{$node1} } ) {
            $out{$node1} += $graph->{$node1}{$node2};
            $in{$node2}  += $graph->{$node1}{$node2};
            if ( !exists $in{$node1} ) {
                $in{$node1} = 0;
            }
            if ( !exists $out{$node2} ) {
                $out{$node2} = 0;
            }
        }
    }

    my @paths;    ## no critic (ProhibitReusedNames)

    foreach my $node ( keys %{$graph} ) {
        next if $in{$node} == 1 && $out{$node} == 1;
        foreach ( 1 .. $out{$node} ) {
            while ( exists $graph->{$node} ) {
                my $next_node = ( keys %{ $graph->{$node} } )[0];
                my @path = ( $node, $next_node );
                while ( $in{$next_node} == 1 && $out{$next_node} == 1 ) {
                    $next_node = ( keys %{ $graph->{$next_node} } )[0];
                    push @path, $next_node;
                }
                push @paths, \@path;
                $graph = remove_path( $graph, \@path );
            }
        }
    }

    return @paths;
}

sub remove_path {
    my ( $graph, $path ) = @_;

    foreach my $i ( 1 .. scalar @{$path} - 1 ) {
        my $node1 = $path->[ $i - 1 ];
        my $node2 = $path->[$i];
        $graph->{$node1}{$node2}--;
        if ( $graph->{$node1}{$node2} == 0 ) {
            delete $graph->{$node1}{$node2};
            if ( scalar keys %{ $graph->{$node1} } == 0 ) {
                delete $graph->{$node1};
            }
        }
    }

    return $graph;
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

contig-generation.pl

Contig Generation

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Contig Generation Problem.

Input: A collection of I<k>-mers I<Patterns>.

Output: All contigs in I<DeBruijn>(I<Patterns>).

=head1 EXAMPLES

    perl contig-generation.pl

    perl contig-generation.pl --input_file contig-generation-extra-input.txt

    diff <(perl contig-generation.pl) contig-generation-sample-output.txt

    diff \
        <(perl contig-generation.pl \
            --input_file contig-generation-extra-input.txt) \
        contig-generation-extra-output.txt

    perl contig-generation.pl --input_file dataset_205_5.txt \
        > dataset_205_5_output.txt

=head1 USAGE

    contig-generation.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A collection of I<k>-mers I<Patterns>".

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
