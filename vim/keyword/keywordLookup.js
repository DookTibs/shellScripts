#!/usr/local/bin/node

// extensible program to make Vim's K command a little more useful/customizable

var http = require("http");

if (process.argv.length == 4) {
	var context = process.argv[2];
	var keyword	 = process.argv[3];
} else {
	console.log("Usage: keywordLookup.js <context> <keyword>");
	return;
}

for (var i = 0 ; i > -1 ; i++) { // WILL RUN FOREVER!!!
	var pathToHelper = "./helpers/" + context + "LookupHelper";
	if (i > 0) { pathToHelper += "_" + (i+1); }

	var helperClass = null;
	try {
		helperClass = require(pathToHelper);
	} catch (e) {
		if (i == 0) {
			console.log("\"" + context + "\" has no custom definition; using default lookup helper");
			helperClass = require("./helpers/defaultLookupHelper");
		} else {
			console.log("giving up...");
			break;
		}
	}

	if (helperClass != null) {
		if (i == 0) {
			console.log("Attempting keyword \"" + keyword + "\" lookup for \"" + context + "\" context...");
		}
		var helper = new helperClass();

		// could be from the web, or a local command, or whatever
		var data = helper.fetchData(keyword);

		// sometimes we want to do some post-processing
		var processedData = helper.processReturnedData(data);

		if (helper.gotGoodResults(data, processedData)) {
			console.log("Got results using \"" + helper.getDescription() + "\" helper.\n=================================================");
			console.log(processedData);
			break;
		} else {
			console.log("No results using \"" + helper.getDescription() + "\" helper.");
		}
	}
}
