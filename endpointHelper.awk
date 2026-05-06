# Helper script that works with endpointSummary.sh
#
# looks at a Java class file and extracts some
# relevant info about its RequestMapping annotations.
#
# Works fine even for annotations that span multiple lines.
#
# probably not perfect in terms of extracting value/method
# and if there are nested parentheses in the annotation (is that
# possible?) it will break. But it works for all the Dragon 
# controllers as of 20170308 so good enough for now.

BEGIN {
	# we are just using awk to process whole lines; we don't want to split
	# so we set FS to some garbage string we won't actually ever encounter
	FS = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	IGNORECASE=1

	# lhsLen = 100
	lhsLen = PAD_WIDTH
	pastClassDeclaration = 0
	processingAnnotation = 0
	currAnnotation = ""
	basePath = ""
	currControllerPath = ""
}

currControllerPath == "" {
	# print "#### STARTING ON " FILENAME " ####"
	if (match(FILENAME, /.*src\/main\/java\/com\/icfi\/dragon\/web(.*)/, a)) {
		currControllerPath = a[1]
	} else {
		currControllerPath = FILENAME
	}
}

match($1, /^public class/) {
	pastClassDeclaration = 1
}

match($1, /@RequestMapping/) {
	processingAnnotation = 1
	currAnnotation = ""
}

processingAnnotation == 1 {
	currAnnotation = currAnnotation $0
}

# doing it this way lets us catch annotations that span multiple lines
processingAnnotation == 1 && match($1, /)/) {
	processingAnnotation = 0
	# print (pastClassDeclaration == 1 ? "method: " : "class: ") currAnnotation
	hasValueAttribute = match(currAnnotation, /value *= *"([{}a-zA-Z\/.]*)"/, a)

	multipleMappings = ""

	valueAttribute = ""
	if (hasValueAttribute > 0) {
		valueAttribute = a[1]
	} else {
		if (match(currAnnotation, /\( *"([{}a-zA-Z\/.]*)" *\)/, a)) {
			valueAttribute = a[1]
		}

		# in spring 2026 we had to rewrite things for Spring.  lines like:
		# @RequestMapping(value = "/steps", method = RequestMethod.GET)
		#
		# were rewritten as:
		# @RequestMapping(value = {"/steps", "/steps/"}, method...
		#
		# the above match doesn't find these! So let's do a bunch of horribly inefficient sub commands
		# to just grab the first version (e.g. "/steps") and we'll leave the rest of the script alone...
		if (match(currAnnotation, /({ *"[^"]*".*})/, a)) {
			multipleMappings = " !!"
			valueAttribute = a[1]
			sub(/,.*/, "", valueAttribute) # if there's a comma, just take the first one
			sub(/}$/, "", valueAttribute) # if there was no comma, strip the trailing }
			sub(/{/, "", valueAttribute) # strip the leading {
			sub(/^[^"]*/, "", valueAttribute) # get anything before the start of the quote
			sub(/^"/, "", valueAttribute) # strip leading quote
			sub(/"$/, "", valueAttribute) # strip trailing quote
		}
	}
	# print "'" currControllerPath "' -- line [" NR "]/[" hasValueAttribute "] VA: " valueAttribute

	path = ""
	if (valueAttribute != "") {
		if (pastClassDeclaration == 0) {
			basePath = valueAttribute
			# print ">>>>>>> basepath set to " basePath
		} else {
			path = basePath "/" valueAttribute
		}
	} else {
		if (pastClassDeclaration == 1) {
			path = basePath
		} else {
			path = "error - couldn't figure out a path"
		}
	}

	if (path != "") {
		path = gensub(/\/\//, "/", "g", path)
		hasMethodAttribute = match(currAnnotation, /method *= *([a-zA-Z\/.]*)/, a)
		method = "GET"
		if (hasMethodAttribute > 0 && match(a[1], /.*POST$/)) {
			method = "POST"
		}

		output = path " (" method ")" multipleMappings
		while (length(output) < lhsLen) {
			output = output " "
		}
		output = output currControllerPath
		output = output " [" NR "]"

		print output
	}
}

END {
	print "----------"
	print "!! indicates an endpoint where multiple RequestMapping values were found mapped to a function."
	print "   e.g. '@RequestMapping(value = {\"/steps\", \"/steps/\"}, method = RequestMethod.GET)'"
	print "   Only the first such value (e.g. '/steps') was printed out above to maintain brevity/sanity."
}
