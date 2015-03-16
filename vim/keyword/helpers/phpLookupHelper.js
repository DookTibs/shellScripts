var WebLookupHelper = require("./webLookupHelper");
var inherits = require("util").inherits;

function PhpLookupHelper() {
	WebLookupHelper.call(this);
}

inherits(PhpLookupHelper, WebLookupHelper);

PhpLookupHelper.prototype.constructUrl = function(keyword) {
	return "http://php.net/manual/en/function." + keyword.replace(/_/g, "-") + ".php";
}

PhpLookupHelper.prototype.getDescription = function() {
	return "php.net";
}

PhpLookupHelper.prototype.gotGoodResults = function(data, processedData) {
	var re = /The manual page you are looking for[\s\S]*is not available/;
	var match = re.exec(processedData);

	if (match != null && match.length == 1) {
		return false;
	} else {
		return true;
	}
}

PhpLookupHelper.prototype.processReturnedData = function(data) {
	var rv = data;
	rv = rv.replace(/[\s\S]*Edit Report a Bug\n*/, "", "g");
	rv = rv.replace(/User Contributed Notes[\s\S]*/, "", "g");
	return rv;
}

module.exports = PhpLookupHelper;
