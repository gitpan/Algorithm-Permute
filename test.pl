# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..16\n"; }
END {print "not ok 1\n" unless $loaded;}
@correct = ("3 2 1", "2 3 1", "2 1 3", "3 1 2", "1 3 2", "1 2 3");

use Algorithm::Permute;
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
