# Helper script that works with hawcEndpointSummary.sh
#
# looks at a Python file and extracts some
# relevant info about its url mappings
#
# Works fine even for annotations that span multiple lines?
#

BEGIN {
	# we are just using awk to process whole lines; we don't want to split
	# so we set FS to some garbage string we won't actually ever encounter
	FS = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	IGNORECASE=1

	# lhsLen = 100
	lhsLen = PAD_WIDTH
	processingUrl = 0
	currUrl = ""
	basePath = ""
	currControllerPath = ""
}

match($1, /\<url\(/) {
	# print $0
	processingUrl = 1
	# currUrl = ""

	# would need to start counting parentheses to properly do multiline ones...work on this later.

	# capture the first argument to the url function; that's the pattern
	parsedUrl = match($0, /url\(r'([^']*)'/, a)

	valueAttribute = ""
	if (parsedUrl > 0) {
		# print a[1]	"\t\t\t" FILENAME
		pattern = a[1]

		# strip the leading "^" and the trailing "$"; visual noise for this report
		if (match(pattern, /^\^(.*)/, goodParts)) { pattern = goodParts[1] }
		if (match(pattern, /(.*)\$$/, goodParts)) { pattern = goodParts[1] }

		# replace things like (?P<pk>\d+) with {pk}
		if (match(pattern, /(.*)\(.*<(.*)>.*\)(.*)/, goodParts)) {
			print "!!!!!"
			pattern = goodParts[1] "{" goodParts[2] "}" goodParts[3]
		}

		pattern = "/" URL_PREFIX pattern

		output = pattern
		while (length(output) < lhsLen) {
			output = output " "
		}
		output = output FILENAME
		output = output " [" NR "]"

		print output
	}
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

	valueAttribute = ""
	if (hasValueAttribute > 0) {
		valueAttribute = a[1]
	} else {
		if (match(currAnnotation, /\( *"([{}a-zA-Z\/.]*)" *\)/, a)) {
			valueAttribute = a[1]
		}
	}

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

		output = path " (" method ")"
		while (length(output) < lhsLen) {
			output = output " "
		}
		output = output currControllerPath
		output = output " [" NR "]"

		print output
	}
}
