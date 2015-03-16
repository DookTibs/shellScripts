var WebLookupHelper = require("./webLookupHelper");
var inherits = require("util").inherits;

function JavascriptLookupHelper_2() {
	WebLookupHelper.call(this);
}

inherits(JavascriptLookupHelper_2, WebLookupHelper);

JavascriptLookupHelper_2.prototype.constructUrl = function(keyword) {
	return "http://api.jquery.com/jquery." + keyword.toLowerCase() + "/";
}

JavascriptLookupHelper_2.prototype.getDescription = function() {
	return "api.jquery.com";
}

JavascriptLookupHelper_2.prototype.gotGoodResults = function(data, processedData) {
	if (processedData == null || data.indexOf("This is somewhat embarrassing, isn't it?") != -1) {
		return false;
	} else {
		return true;
	}
}

JavascriptLookupHelper_2.prototype.processReturnedData = function(data) {
	var rv = data;

	var re = new RegExp("[\\s\\S]*?jQuery." + this.storedKeyword);
	rv = "jQuery." + this.storedKeyword + rv.replace(re, "");

	var re = /([\s\S]*)(.*\*.*Ajax[\s\S]*Global Ajax Event Handlers).*/;
	var match = re.exec(rv);
	
	if (match == null) {
		rv = null;
	} else {
		rv = match[1];
	}
	
	return rv;
}

module.exports = JavascriptLookupHelper_2;
