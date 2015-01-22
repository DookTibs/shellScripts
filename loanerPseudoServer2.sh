#!/usr/local/bin/node
// attempt two - just use this and launch this and start chromix server manually. Simpler to follow than the netcat/fifo approach
var sys = require("sys"), child_process = require("child_process"), my_http = require("http");

my_http.createServer(function(request,response){  
	if (request.url == "/foo") {
		sys.puts("exe foo cmd");

		child_process.exec('chromix with "random.org" reload');
	} else if (request.url == "/bar") {
		sys.puts("exe bar cmd");
		child_process.exec('chromix with "tibs=bar" reload');
	} else {
		sys.puts("unsupported command [" + request.url + "]");
	}
	response.end();  
}).listen(2999);  
sys.puts("Server Running on 2999");   
