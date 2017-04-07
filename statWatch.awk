# script that looks at Tomcat's catalina.out file past a certain point
# and sums up some stats when doing a DRAGON migration. These are super
# long running operations and I have found breaking them into bits is 
# the only way to get them to finish without crashing.
# 
# this isn't a super interesting script, but it is a decent example of
# things in (g)awk like BEGIN/END, line numbers, associative arrays, 
# regex group capturing, etc.
# 
# use like "awk -f <pathToThisFile> <pathToCatalina.out>

# let's make sure that step 36 actually had stuff save...if not, that means we have
# a fencepost problem for ALL of the steps.
BEGIN {
	FS = "|"
	allDoneWithSS = 0
	numSS = 0
	lastStepFound = ""
	startPrintingSteps = 0
	numStepsTotal = 0
}

# 28555
NR < 30846 { next }

match($5, /ACTUALLY WORK ON SAVED STEPS:/, a) {
	startPrintingSteps = 1
	print "Processing steps:"
}

match($5, /Fetching studyDragonIdsAsLong.*/, a) {
	startPrintingSteps = 0
	print "============="
}

match($5, / (.*) - (.*)/, a) && startPrintingSteps == 1 {
	trimmedStepName = substr(a[2], 0, length(a[2]) - 1)
	print "\t" trimmedStepName " (" a[1] ")"
	numStepsTotal += 1
}


match($5, /Started migrating study statuses for.*step (.*)/, a) {
	trimmedStep = substr(a[1], 0, length(a[1]) - 1)
	# print "started on [" trimmedStep "]"
	stepStorage[trimmedStep] = 0
	lastStepFound = trimmedStep
}

match($5, /Finished migrating (.*) study statuses.*step (.*)/, a) {
	trimmedStep = substr(a[2], 0, length(a[2]) - 1)
	# print "Got [" a[1] "] studies for [" trimmedStep "]"
	stepStorage[trimmedStep] += a[1]
	numSS += a[1]
}

match($5, /Finished migrating study statuses.*/, a) {
	allDoneWithSS = 1
}

END {
	looper = 1
	numStepsFinished = length(stepStorage)
	if (allDoneWithSS == 0) {
		numStepsFinished -= 1
	}

	print numStepsFinished "/" numStepsTotal " steps processed completely" (numStepsFinished != length(stepStorage) ? " (step " lastStepFound " in progress)" : "")
	for (stepId in stepStorage) {
		# print "Step " stepId ": " stepStorage[stepId] "+" (looper <= numStepsFinished ? " (fully imported)" : "")
		print "Step " stepId ": " stepStorage[stepId] "+"
		looper = looper + 1
	}
	print "Total study statuses imported: " numSS "+"
}
