var WebLookupHelper = require("./webLookupHelper");
var inherits = require("util").inherits;

function PhpLookupHelper() {
	WebLookupHelper.call(this);
}

inherits(PhpLookupHelper, WebLookupHelper);

PhpLookupHelper.prototype.constructUrl = function(keyword) {
	return "http://php.net/manual/en/function." + keyword.replace(/_/, "-", "g") + ".php";
}

PhpLookupHelper.prototype.processReturnedData = function(data) {
	var rv = data;
	rv = rv.replace(/[\s\S]*Edit Report a Bug\n*/, "", "g");
	rv = rv.replace(/User Contributed Notes[\s\S]*/, "", "g");
	return rv;
}

module.exports = PhpLookupHelper;
