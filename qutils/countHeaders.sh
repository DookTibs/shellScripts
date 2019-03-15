#!/usr/bin/env python

import sys, csv

# returns count of number of headers

def processLine(source, contents):
	fakeList = contents.split("\n")

	reader = csv.reader(fakeList)
	for headers in reader:
		return len(headers)

if __name__ == "__main__":
	numHeaders = None
	if len(sys.argv) == 2:
		with open(sys.argv[1]) as f:
			for line in f:
				numHeaders = processLine("FILE", line)
				break
	else:
		for line in sys.stdin:
			numHeaders = processLine("STDIN", line)
			break
	print numHeaders
