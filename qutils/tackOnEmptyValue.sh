#!/usr/bin/env python

import sys, csv

def processLine(source, contents):
	print("PROCESSING [%s]" % contents)
	"""
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
	"""
	return "X"

if __name__ == "__main__":
	if len(sys.argv) == 2:
		print(processLine("RAW", sys.argv[1]))
