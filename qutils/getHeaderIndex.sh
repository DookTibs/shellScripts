#!/usr/bin/env python

import sys, csv

# given a header by name of 'foo', return 0-based index of it in the list of all headers, or None if not found

def processLine(source, contents, targetHeader):
	fakeList = contents.split("\n")

	reader = csv.reader(fakeList)
	for headers in reader:
		idx = 0
		for header in headers:
			if header == targetHeader:
				return idx
			idx += 1
		break

	return -1

if __name__ == "__main__":
	headerIdx = -1
	if len(sys.argv) == 3:
		with open(sys.argv[1]) as f:
			for line in f:
				headerIdx = processLine("FILE", line, sys.argv[2])
				break
	elif len(sys.argv) == 2:
		for line in sys.stdin:
			headerIdx = processLine("STDIN", line, sys.argv[1])
			break
	print headerIdx
