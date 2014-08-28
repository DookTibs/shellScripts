#!/usr/bin/perl -w
use strict;

# see http://stackoverflow.com/questions/5245087/math-operations-in-regex
# very easy, assuming you can write a little perl!

my $file = 'steve.txt';
open my $info, $file or die "Could not open $file: $!";

print "going to try to increment values that are >= 3...\n\n";
while( my $line = <$info>)  {   
	$line =~ s/\n//;

	my $modified = $line;

	# test 1 - can we perform a simple regex (I don't know perl!)
	# $modified =~ s/hello/goodbye/;

	# test 2 - can we do captures
	# $modified =~ s/([a-z]*)(\d*)/$1_$2/;

	# test 3 - can we do some math
	# $modified =~ s/([a-z]*)(\d*)/"$1_" . ($2+1)/e;

	# test 4 - can we do some conditional math - only bump if >= 3
	$modified =~ s/([a-z]*)(\d*)/"$1_" . ($2 >= 3 ? $2+1 : $2)/e;

	print "line is: [$line], modified line is [$modified]\n";
	# last if $. == 2;
}

print "--- DONE ---\n";

close $info;
