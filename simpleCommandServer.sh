#!/usr/local/bin/node
// Lightweight server that accepts requests over http on a configurable port, and runs
// commands on the host in a safe and flexible manner. Commands MUST be defined in the 
// "cmdMaps" object; users can pass in params.
// Ex: http://localhost:port/<CMD>/paramOne/paramTwo
// see also netcatLoanerPseudoServer.sh for an early experiment in a different direction
//
// Real power of this comes from when I am splitting my work over multiple computers / servers but still
// want to do stuff like reload webpages with chromix, access helper scripts, etc.
// 
// I have at least two use cases for this:
// 1. borrowing a loaner laptop for a trip
//		In this case, I run simpleCommandServer on the loaner, and then run "connectToOffice.sh" to ssh/tunnel/portforward
//		back to my main Carleton desktop. Once there I can call 'curl localhost:XXXX/command' which will talk back
//		to the loaner laptop and run commands there (typically, reload a webpage of interest)
// 
// 2. ssh'ing to a server like the one for CLAMP development work
//		In this case, I run simpleCommandServer on my main Carleton desktop, and then run something like "connectToMitre.sh"
//		to ssh/tunnel/portforward to that server. Again I can curl localhost and talk back to my desktop, which 
//		can be used to reload webpages or run other things (like vimKeywordLookup.js for instance...). Commands
//		can accept user input; for instance the "vk" command can be called via, for example,
//		"curl -s localhost:2499/vk/php/implode | less" -- 'php' and 'implode' are passed to the keywordLookup.js program
//		and output is piped (or redirected, or what have you). This lets me do stuff like use my nice customized
//		scripts that are installed in just one place, even if I'm ssh'ed in someplace else. (and I can't just do them
//		over ssh as my machine is not visible to the internet, and I don't want to always multihop through the gateway)

var sys = require("sys"), child_process = require("child_process"), my_http = require("http");

// see https://blog.liftsecurity.io/2014/08/19/Avoid-Command-Injection-Node.js for 
// a good discussion of how to be safe with this approach

// be sure to start chromix manually (chromix-server) for chromix commands
var cmdMaps = {
	"vk": {
		command: "/Users/tfeiler/development/shellScripts/vim/keyword/keywordLookup.js",
		returnResults: true
	},
	"random": {
		command: "chromix",
		params: ["with", "random.org", "reload"]
	}
};

var sensitiveBashScript = process.env.HOME + "/development/configurations/bash/sensitive_data.bash";
child_process.exec('source', [sensitiveBashScript], function() {
	var portToListenOn;
	if (process.argv.length == 3) {
		portToListenOn = process.argv[2];
	} else {
		portToListenOn = process.env._TJF_COMMANDSERVER_PORT;
	}

	my_http.createServer(function(request,response){  
		var mapKey = request.url.substring(1);

		// are there additional params passed in by user?
		var slashIdx = mapKey.indexOf("/");
		var userInputParams = [];
		if (slashIdx != -1) {
			userInputParams = mapKey.substring(slashIdx+1).split("/");
			mapKey = mapKey.substring(0, slashIdx);
		}

		var mappedCmd = cmdMaps[mapKey];

		if (mappedCmd != undefined) {
			sys.puts("execing [" + mappedCmd.command + "]...");
			// child_process.exec(mappedCmd);
			var commandParams = mappedCmd.params ? mappedCmd.params : [];
			var spawnedProc = child_process.spawn(mappedCmd.command, commandParams.concat(userInputParams));

			spawnedProc.stderr.on('data', function(data) {
				console.log("stderr: " + data);	
			});

			if (mappedCmd.returnResults) {
				// response.writeHead(200, {"Content-Type": "text/plain"});

				spawnedProc.stdout.on('data', function(data) {
					console.log("stdout: " + data);
					response.write(data.toString());
				});

				spawnedProc.on('close', function(code) {
					console.log("close: exited with code '" + code + "'");
					response.end();
				});
			} else {
				response.end();  
			}
		} else {
			sys.puts("unsupported command [" + request.url + "]");
		}

	}).listen(portToListenOn);  
	sys.puts("command server Running on " + portToListenOn);
});
