#   Permute.pm
#
#   Copyright (c) 1999,2000 Edwin Pratomo
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file,
#   with the exception that it cannot be placed on a CD-ROM or similar media
#   for commercial distribution without the prior approval of the author.

package Algorithm::Permute;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

$VERSION = '0.02';

bootstrap Algorithm::Permute $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Algorithm::Permute - Handy and fast permutation with object oriented interface

=head1 SYNOPSIS

  use Algorithm::Permute;

  $p = new Algorithm::Permute(['a'..'d']);
  while (@res = $p->next) {
    print join(", ", @res), "\n";
  }

=head1 DESCRIPTION

This handy module makes performing permutation in Perl easy and fast, 
although perhaps its algorithm is not the fastest on the earth. 
Currently it only supports permutation n of n objects. 

No exported functions. This version is not backward compatible with the
previous one, version 0.01. The old interface is no longer supported.

=head1 METHODS

=over 4

=item new [@list]

Returns a permutor object for the given items. 

=item next

Returns a list of the items in the next permutation. 
The order of the resulting permutation is the same as of the previous version 
of C<Algorithm::Permute>.

=item peek

Returns the list of items which B<will be returned> by next(), but
B<doesn't advance the sequence>. Could be useful if you wished to skip
over just a few unwanted permutations.

=item reset

Resets the iterator to the start. May be used at any time, whether the
entire set has been produced or not. Has no useful return value.

=back

=head1 COMPARISON

I've collected some Perl routines and modules which implement permutation,
and do some simple benchmark. The result, which is of course predictable, 
and obvious, is the following.

Permutation of B<eight> scalars:

 Abigail's: 14 wallclock secs (13.21 usr +  0.49 sys = 13.70 CPU)
 Algorithm::Permute: 3 wallclock secs ( 2.96 usr +  0.02 sys =  2.98 CPU)
 List::Permutor:  9 wallclock secs ( 8.98 usr +  0.02 sys =  9.00 CPU)
    MJD's: 56 wallclock secs (55.54 usr +  0.18 sys = 55.72 CPU)
 perlfaq4: 65 wallclock secs (64.71 usr +  0.22 sys = 64.93 CPU)

Permutation of B<nine> scalars (the Abigail's routine is commented out, because
it stores all of the result in memory, swallows all of my machine's memory):

 Algorithm::Permute: 14 wallclock secs (14.13 usr + 0.07 sys = 14.20 CPU)
 List::Permutor: 67 wallclock secs (65.78 usr +  0.47 sys = 66.25 CPU)
    MJD's: 530 wallclock secs (516.57 usr +  2.10 sys = 518.67 CPU)
 perlfaq4: 498 wallclock secs (490.49 usr +  1.65 sys = 492.14 CPU)

The benchmark script is included in the bench directory. I understand that 
speed is not everything. So here is the list of URLs of the alternatives, in 
case you hate this module.

=over 4

=item * 
Mark Jason Dominus' technique is discussed in chapter 4 Perl Cookbook, so you 
can get it from O'Reilly: 
ftp://ftp.oreilly.com/published/oreilly/perl/cookbook

=item *
Abigail's: http://www.foad.org/~abigail/Perl

=item *
List::Permutor: http://www.cpan.org/modules/by-module/List

=item *
The classic way, usually used by Lisp hackers: perldoc perlfaq4

=back

=head1 HISTORY

=over 4

=item *

September 2, 2000 - version 0.02. Major interface changes, now using object
oriented interface similar to C<List::Permutor>'s. More efficient memory 
usage. Internal tweaking gives speed improvement - the list elements are no 
longer swapped, but only the indexes.

=item *

October 3, 1999 - Alpha release, version 0.01 

=back

=head1 AUTHOR

Edwin Pratomo, I<ed.pratomo@computer.org>. The object oriented interface is
taken from Tom Phoenix's C<List::Permutor>.

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
