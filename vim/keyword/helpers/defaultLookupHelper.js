var execSync = require("sync-exec");

// default behavior - call "man" on the keyword

function DefaultLookupHelper() {
}

DefaultLookupHelper.prototype.fetchData = function(keyword) {
	var cmd = "man " + keyword;
	try {
		var data = execSync(cmd);
		return data;
	} catch (e) {
		return null;
	}

}

DefaultLookupHelper.prototype.getDescription = function() {
	return "man pages";
}

DefaultLookupHelper.prototype.gotGoodResults = function(data, processedData) {
	return data != null;
}

DefaultLookupHelper.prototype.processReturnedData = function(data) {
	return data;
}

module.exports = DefaultLookupHelper;
