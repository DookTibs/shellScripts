#!/usr/bin/perl -w
# w = warnings
use strict;

# this can be used with something like:
# alias chromelog='tail -f /Users/tfeiler/Library/Application\ Support/Google/Chrome/chrome_debug.log'
# chromelog | filterChromeConsole.sh



# see http://stackoverflow.com/questions/5245087/math-operations-in-regex
# very easy, assuming you can write a little perl!

# flush stdout
local $| = 1;

while (<>) {
	my $line = $_;
	# print "FROM PERLY: $line";

	if ($line =~ m/CONSOLE/) {
		my $massaged = $line;
		$massaged =~ s/(.*?)"(.*)", source.*/$2/e;
		print $massaged
	}
}
