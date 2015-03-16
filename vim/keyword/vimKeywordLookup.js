#!/usr/local/bin/node

// extensible program to make Vim's K command a little easier to customize.

var http = require("http");

if (process.argv.length == 4) {
	var context = process.argv[2];
	var keyword	 = process.argv[3];
} else {
	console.log("Usage: vimKeywordLookup.js <context> <keyword>");
	return;
}

var pathToHelper = "./helpers/" + context + "LookupHelper";
var helperClass = null;
try {
	helperClass = require(pathToHelper);
} catch (e) {
	console.log("\"" + context + "\" has no custom definition; using default lookup helper");
	helperClass = require("./helpers/defaultLookupHelper");
}

// todo - allow for multiple types of lookups (ie hit w3 first, then jquery for javascript lookups)
var helper = new helperClass();

// could be from the web, or a local command, or whatever
var data = helper.fetchData(keyword);

// sometimes we want to do some post-processing
var processedData = helper.processReturnedData(data);

if (helper.gotGoodResults(data, processedData)) {
	console.log(processedData);
} else {
	console.log("bad results...");
}
