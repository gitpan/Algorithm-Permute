#!/nfs1/local/bin/perl -w
package Combinatorial::Permutations;

use strict;
use Exporter;

use vars qw /@EXPORT @EXPORT_OK @ISA/;

@ISA       = qw /Exporter/;
@EXPORT    = ();
@EXPORT_OK = qw /permutate/;

sub permutate (@);

# Return a list of permutations of the given list.
sub permutate (@) {
    return () unless @_;
    my $first = shift;
    return ([$first]) unless @_;

    map {my $row = $_;
         map {my $tmp = [@$row];
              splice @$tmp, $_, 0, $first; $tmp;} (0 .. @$row);} permutate @_;
}


1;
