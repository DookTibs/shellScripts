#!/usr/local/bin/node
// just use this and launch this and start chromix server manually (chromix-server). Simpler to follow than the netcat/fifo approach

var sys = require("sys"), child_process = require("child_process"), my_http = require("http");

var cmdMaps = {
	"graveyard": 'chromix with "testpage3" reload',
	"random": "chromix with 'random.org' reload"
};

var sensitiveBashScript = process.env.HOME + "/development/configurations/bash/sensitive_data.bash";
child_process.exec('source', [sensitiveBashScript], function() {
	var portToListenOn = process.env._TJF_LOANER_CMDSERVER_PORT;

	my_http.createServer(function(request,response){  
		var mapKey = request.url.substring(1);
		var mappedCmd = cmdMaps[mapKey];

		if (mappedCmd != undefined && mappedCmd != "") {
			sys.puts("execing [" + mappedCmd + "]...");
			child_process.exec(mappedCmd);
		} else {
			sys.puts("unsupported command [" + request.url + "]");
		}

		response.end();  
	}).listen(portToListenOn);  
	sys.puts("command server Running on " + portToListenOn);
});
