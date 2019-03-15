#!/usr/bin/env python

import sys, csv

# simple python script that takes in a csv and attempts to fix missing column names. q (http://harelba.github.io/q/)
# barfs if any column headers are missing. This makes it possible to work with it.
#
# so like if:
#		cat foo.csv | q -d "," -H "SELECT bar FROM -"
# makes q complain that htere are missing headers, you can do
#		cat foo.csv | headerFixer.sh | q -d "," -H "SELECT bar FROM -"
#
# This will either read from a file supplied as only argument, or from stdin. It will spit out results to stdout.

def processLine(source, counter, contents):
	# print("%s [%s]: [%s]" % (source, counter, contents))
	if counter == 0:
		fakeList = contents.split("\n")

		reader = csv.reader(fakeList)
		missingHeaderCounter = 1
		fixedHeaders = ""
		for headers in reader:
			for header in headers:
				if fixedHeaders != "":
					fixedHeaders += ","

				if header == "":
					fixedHeaders += "\"missing_" + str(missingHeaderCounter) + "\""
					missingHeaderCounter += 1
				else:
					fixedHeaders += "\"" + header + "\""
			break

		print fixedHeaders
	else:
		sys.stdout.write(contents)
	
	if counter % 10 == 0:
		sys.stdout.flush()

if __name__ == "__main__":
	lineCounter=0
	if len(sys.argv) == 2:
		with open(sys.argv[1]) as f:
			for line in f:
				processLine("FILE", lineCounter, line)
				lineCounter += 1
	else:
		for line in sys.stdin:
			processLine("STDIN", lineCounter, line)
			lineCounter += 1
	sys.stdout.flush()
