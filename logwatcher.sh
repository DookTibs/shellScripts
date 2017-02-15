#!/usr/bin/python

# python script that watches a log file (file must exist!).
# when it sees matching text, it exits and prints that line.
# I use this for things like Tomcat utility scripts - I can kick off
# longrunning background tasks and then watch a logfile to know
# when the server is *really* up.

# follow generator from http://stackoverflow.com/a/3290355

import time, sys, re

def follow(thefile):
    thefile.seek(0,2) # Go to the end of the file
    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.1) # Sleep briefly
            continue
        yield line

if len(sys.argv) != 3:
    print "Usage: logwatcher.sh <logfile> <searchPattern>"
    sys.exit(1)

logToWatch = sys.argv[1]
searchPattern = sys.argv[2]

# print "Watching '" + logToWatch + "' for '" + searchPattern + "'"

f = file(logToWatch)

regex = re.compile(searchPattern)

targetLine = ""
for l in follow(f):
    l = l[:-1]
    if (regex.search(l) != None):
        targetLine = l
        break

print targetLine
