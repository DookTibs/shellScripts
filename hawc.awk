BEGIN {
	# we are just using awk to process whole lines; we don't want to split
	# so we set FS to some garbage string we won't actually ever encounter
	FS = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	IGNORECASE=1

	currPrefix = ""
}

match($1, /\<url\(r'([^']*)'/, a) {
	pattern = a[1]

	# strip the leading "^" and the trailing "$"; visual noise for this report
	if (match(pattern, /^\^(.*)/, goodParts)) { pattern = goodParts[1] }
	if (match(pattern, /(.*)\$$/, goodParts)) { pattern = goodParts[1] }

	# print pattern
	currPrefix = pattern
}

# currPrefix tells us the start of the URL; next we need to see some other values
currPrefix != "" && match($0, /.*include\(.*/) {
	chunk = $0

	# we're looking at a prefix, now extract the "include(....)" value so we 
	# know the next file to look at
	if (match(chunk, /.*include\('*([^)]*)'*).*/, a)) {
		nextFile = a[1]
		if (match(a[1], /(.*)',.*/, b)) {
			nextFile = b[1]
		}

		if (match(nextFile, /(.*)'/, c)) {
			nextFile = c[1]
		}
		# print currPrefix "\t" nextFile
		print currPrefix
		print nextFile

		# system("echo " currPrefix " " nextFile " | awk -f /Users/tfeiler/development/shellScripts/hawc2.awk")
	}
}

