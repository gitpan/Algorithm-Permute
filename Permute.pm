package Algorithm::Permute;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(permute permute_ref);

$VERSION = '0.01';

bootstrap Algorithm::Permute $VERSION;

1;
__END__

=head1 NAME

Algorithm::Permute - Perl extension for easy and fast permutation

=head1 SYNOPSIS

  use Algorithm::Permute qw(permute permute_ref);
  
  @result = permute([1..4]);
  for (@result) {
	  print join(', ', @$_), "\n";
  }

or:

  $result_ref = permute_ref(['a'..'e']);
  for (@$result_ref) {
	  print join(', ', @$_), "\n";
  }

=head1 DESCRIPTION

This module makes performing permutation in Perl easy and fast, although 
perhaps its algorithm is not the fastest on the earth. 
Currently it only supports permutation n of n objects. 

Two functions are available to be imported into the caller's
namespace: C<permute()> and C<permute_ref()>. Both functions take a
reference to an array as the argument. C<permute()> returns an array
containing anonymous arrays, C<permute_ref()> returns a reference to an
array.


=head1 HISTORY

=over 2

=item *

October 3, 1999 - Alpha release, version 0.01 

=back


=head1 AUTHOR

Edwin Pratomo, I<ed.pratomo@computer.org>

=head1 ACKNOWLEDGEMENT

Yustina Sri Suharini - my fiance, for providing the permutation problem to
me.

=head1 SEE ALSO

=over 2

=item * B<Data Structures, Algorithms, and Program Style Using C> - 
Korsh and Garrett

=item * B<Algorithms from P to NP, Vol. I> - Moret and Shapiro

=back

=cut
