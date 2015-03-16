var WebLookupHelper = require("./webLookupHelper");
var inherits = require("util").inherits;

function JavascriptLookupHelper() {
	WebLookupHelper.call(this);
}

inherits(JavascriptLookupHelper, WebLookupHelper);

JavascriptLookupHelper.prototype.constructUrl = function(keyword) {
	return "http://www.w3schools.com/jsref/jsref_" + keyword.toLowerCase() + ".asp";
}

JavascriptLookupHelper.prototype.processReturnedData = function(data) {
	var rv = data;
	rv = rv.replace(/[\s\S]*HTML Objects[\s\S]*<video>\n\nJavaScript/, "", "g");
	// rv = rv.replace(/User Contributed Notes[\s\S]*/, "", "g");

	var re = /([\s\S]*Try it yourself..)?([\s\S]*)/;
	var match = re.exec(rv);
	rv = match[1];
	
	rv = "JavaScript" + rv;
	return rv;
}

module.exports = JavascriptLookupHelper;
