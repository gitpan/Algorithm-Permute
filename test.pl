# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..23\n"; }
END {print "not ok 1\n" unless $loaded;}
@correct = ("3 2 1", "2 3 1", "2 1 3", "3 1 2", "1 3 2", "1 2 3");

use Algorithm::Permute qw(permute);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$perm = Algorithm::Permute->new([1..3]);
print ( $perm ? "ok 2\n" : "not ok 2\n");

# peek..
@peek = $perm->peek;
print "# @peek.\nnot " unless "@peek" eq $correct[0];
print "ok 3\n";

# next..
while (@res = $perm->next) {
	print "# @res.\nnot " unless "@res" eq $correct[$cnt++];
	print ("ok ". ($cnt + 3) . "\n");
}

# reset..
$cnt = 0;
$perm->reset;
while (@res = $perm->next) {
	print "# @res.\nnot " unless "@res" eq $correct[$cnt++];
	print "ok ". ($cnt + 9) . "\n";
}

print $cnt == 6 ? "ok 16\n" : "not ok 16\n";

# Tests for the callback interface by Robin Houston <robin@kitsite.com>

my @array = (1..9);
my $i = 0;
permute { ++$i } @array;

print ($i == 9*8*7*6*5*4*3*2*1 ? "ok 17\n" : "not ok 17\n");
print ($array[0] == 1 ? "ok 18\n" : "not ok 18\n");

@array = ();
$i = 0;
permute { ++$i } @array;
print ($i == 0 ? "ok 19\n" : "not ok 19\n");

@array = ('A'..'E');
my @foo;
permute { @foo = @array; } @array;

my $ok = ( join("", @foo) eq join("", reverse @array) );
print ($ok ? "ok 20\n" : "not ok 20\n");

tie @array, 'TieTest';
permute { $_ = "@array" } @array;
print (TieTest->c() == 600 ? "ok 21\n" : "not ok 21\t# ".TieTest->c()."\n");

untie @array;
@array = (qw/a r s e/);
$i = 0;
permute {eval {goto foo}; ++$i } @array;
if ($@ =~ /^Can't "goto" out/) {
    print "ok 22\n";
} else {
    foo: print "not ok 22\t# $@\n";
}

print ($i == 24 ? "ok 23\n" : "not ok 23\n");

my $c;
package TieTest;
sub TIEARRAY  {bless []}
sub FETCHSIZE {5}
sub FETCH     { ++$c; $_[1]}
sub c         {$c}
