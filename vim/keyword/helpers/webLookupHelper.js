var execSync = require("exec-sync");

// base class for lookup helpers that need to go out to the internet to fetch documentation

var DefaultLookupHelper = require("./defaultLookupHelper");
var inherits = require("util").inherits;

function WebLookupHelper() {
	DefaultLookupHelper.call(this);
}

inherits(WebLookupHelper, DefaultLookupHelper);

WebLookupHelper.prototype.constructUrl = function(keyword) {
	console.log("ERROR - constructUrl not implemented for this subclass!");
	return "";
}

WebLookupHelper.prototype.fetchData = function(keyword) {
	var url = this.constructUrl(keyword);
	// console.log("url is [" + url + "]");
	var cmd = "lynx -dump -nolist " + url;
	// console.log("cmd is [" + cmd + "]");
	var data = execSync(cmd);
	// console.log(data);
	return data;
}

module.exports = WebLookupHelper;