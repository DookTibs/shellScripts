#!/usr/bin/env python

import sys, csv

def processLine(source, contents, targetHeader):
	fakeList = contents.split("\n")

	reader = csv.reader(fakeList)
	cleanHeaders = []
	foundHeader = False
	for headers in reader:
		idx = 0
		for header in headers:
			cleanHeaders.append("\"" + header + "\"")
			if header == targetHeader:
				foundHeader = True
				break
			idx += 1
		break

	if foundHeader:
		return contents
	else:
		cleanHeaders.append("\"" + targetHeader + "\"")
		return ",".join(cleanHeaders)

if __name__ == "__main__":
	fixedHeaders = ""
	if len(sys.argv) == 3:
		with open(sys.argv[1]) as f:
			for line in f:
				fixedHeaders = processLine("FILE", line, sys.argv[2])
				break
	elif len(sys.argv) == 2:
		for line in sys.stdin:
			fixedHeaders = processLine("STDIN", line, sys.argv[1])
			break
	
	print fixedHeaders
