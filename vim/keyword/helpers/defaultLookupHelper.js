var execSync = require("exec-sync");

// default behavior - call "man" on the keyword

function DefaultLookupHelper() {
}

DefaultLookupHelper.prototype.fetchData = function(keyword) {
	var cmd = "man " + keyword;
	var data = execSync(cmd);

	return data;
}

DefaultLookupHelper.prototype.gotGoodResults = function(data, processedData) {
	return true;
}

DefaultLookupHelper.prototype.processReturnedData = function(data) {
	return data;
}

module.exports = DefaultLookupHelper;
