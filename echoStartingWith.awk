#! /usr/bin/awk -f
#
# Awk script that does nothing until it observes SOMETHING in it's (typically piped stdin) input.
# from that point on, starts printing things out.
#
# For instance -- maybe I want to hide a bunch of early output from something and just get once something happens (maybe
# I'm debugging, compiling, etc.). So something like:
#
# mvn clean package | echoStartingWith.awk -v pattern="INFO.*errors" | vi -
#

BEGIN {
	# print "setup; pattern to look for is '", pattern, "'"
	DO_PRINT=0

	if((pattern=="") || (pattern==0)) {
		print "No pattern supplied; try like 'echoStartingWith.awk -v pattern=\"something\"'"
		exit 1
	}
}

$0~pattern {
	if (DO_PRINT == 0) {
		DO_PRINT=1
		# print "start printing at line", NR
	}
}

DO_PRINT == 1 {
	print $0
}
