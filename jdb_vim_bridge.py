#!/usr/bin/python

import time, sys, re, json, socket, threading, socketserver

# class that watches a debugger log (jdb only supported one now) and 
# fires off related updates to a connected Vim channel. See also
# ~/development/configurations/vim/tibs_jdb.vim. Right now this type of
# setup only supports a few options but I hope to build it out slowly
# over time so I can stay in tmux even when debugging.

thesocket = None

class ThreadedTCPRequestHandler(socketserver.BaseRequestHandler):

    def handle(self):
        print("=== socket opened ===")
        global thesocket
        thesocket = self.request
        while True:
            try:
                data = self.request.recv(4096).decode('utf-8')
            except socket.error:
                print("=== socket error ===")
                break
            except IOError:
                print("=== socket closed ===")
                break
            if data == '':
                print("=== socket closed ===")
                break
            print("received: {0}".format(data))
            try:
                decoded = json.loads(data)
            except ValueError:
                print("json decoding failed")
                decoded = [-1, '']

            # Send a response if the sequence number is positive.
            # Negative numbers are used for "eval" responses.
            if decoded[0] >= 0:
                if decoded[1] == 'hello!':
                    response = "got it"
                else:
                    response = "what?"
                encoded = json.dumps([decoded[0], response])
                print("sending {0}".format(encoded))
                self.request.sendall(encoded.encode('utf-8'))
        thesocket = None

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

# takes raw output from JDB and parses it out a bit to make it easier for Vim to handle
def createPayload(batch):
    payload = None
    if len(batch) > 0:
        # two problems - 1. I compile the regexes every time this function fires
        #                2. I run the regex a second time if it matches.
        # 
        # See http://stackoverflow.com/questions/2554185/match-groups-in-python
        # for an idea on how to improve problem two. Problem one I just need to 
        # compile these once outside the function. Maybe rewrite whole thing as a 
        # class at some point; would let me add support for other debuggers
        # that way
        listBreakpointsPattern = re.compile("Breakpoints set:")
        addedBreakpointPattern = re.compile("Set breakpoint (.*):(.*)")
        removedBreakpointPattern = re.compile("Removed: breakpoint (.*):(.*)")
        stoppedPattern = re.compile("(Breakpoint hit|Step completed): \"(.*)\", (.*), line=(.*) bci=(.*)")

        if (batch[0] == "> "):
            batch = batch[1:]

        firstLine = batch[0]
        print(f"firstLine: [{firstLine}]")
        if len(batch) > 1:
            print(f"\ttotal additional lines: {len(batch)-1}")
            for i in range(1, len(batch)):
                print(f"\t[{i}]: {batch[i]}")

        if (listBreakpointsPattern.match(firstLine)):
            bps = [
                # hardcoded test data
                { "class": "com.icfi.dragon.web.controller.AssessmentLiteratureManagementController", "line": 1 },
                { "class": "com.icfi.dragon.web.controller.AssessmentLiteratureManagementController", "line": 2 }
            ]
            payload = {
                "type": "breakpoint_list",
                "breakpoints": bps
            }
        elif (addedBreakpointPattern.match(firstLine)):
            lazy = addedBreakpointPattern.match(firstLine)
            bp = { "class": lazy.group(1), "line": lazy.group(2) }
            payload = {
                "type": "breakpoint_added",
                "breakpoint": bp
            }
        elif (removedBreakpointPattern.match(firstLine)):
            lazy = removedBreakpointPattern.match(firstLine)
            bp = { "class": lazy.group(1), "line": lazy.group(2) }
            payload = {
                "type": "breakpoint_removed",
                "breakpoint": bp
            }
        elif (stoppedPattern.match(firstLine)):
            lazy = stoppedPattern.match(firstLine)
            fxn = lazy.group(3)

            # this MIGHT be the path to the file; Vimscript can try to open it up
            pathGuess = fxn.replace(".", "/")
            pathGuess = "/".join(pathGuess.split("/")[0:-1]) + ".java"

            payload = {
                "type": "execution_paused",
                "subtype": lazy.group(1).lower(),
                "context": lazy.group(2),
                "possiblePartialFilePath": pathGuess,
                "function": fxn,
                "lineNumber": int(lazy.group(4).replace(",","")),
                "byteCodeIndex": lazy.group(5),
            }


    if payload == None:
        payload = {
            "type": "raw",
            "data": batch
        }

    return payload

# follow generator from http://stackoverflow.com/a/3290355
def follow(thefile):
    thefile.seek(0,2) # Go to the end of the file
    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.1) # Sleep briefly
            continue
        yield line

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: jdb_vim_bridge.sh <logfile> <port>")
        sys.exit(1)

    logToWatch = sys.argv[1]
    port = int(sys.argv[2])

    print("-----------------------------------------------------------------------")
    print(f"If you haven't already, start jdb like \"jdb <jdbArgs> | tee -a {logToWatch}\"")
    print("From NeoVim, run \":let channel = sockconnect('tcp', 'localhost:" + str(port) + "', { 'on_data': 'NameOfVimscriptFunctionToFire' })\"")
    print("Runs forever; CTRL-C to exit (kill Vim channel too)")
    print("-----------------------------------------------------------------------")

    server = ThreadedTCPServer(("localhost", port), ThreadedTCPRequestHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()

    f = open(logToWatch)

    # jdb shows a ">" to user. Commands are entered. It then spits a bunch of stuff out and 
    # prints a prompt again. We can use this to determine end of output and buffer it up
    # and send it to Vim in a single JSON call (hopefully!). If we're in the middle of a run,
    # the prompt changes.
    endOfOutput = ">"
    altEndOfOutput = "http-nio"
    altRegex = re.compile(altEndOfOutput)

    bufferedOutput = []
    for l in follow(f):
        l = l[:-1]
        if (l == endOfOutput or altRegex.match(l) ):
            bufferedOutput = [line.replace("\t", "").replace("\r", "") for line in bufferedOutput]
            bufferedOutput = list(filter(lambda x: x.strip() != "", bufferedOutput)) # strip empty lines
            if (len(bufferedOutput) > 0):
                payload = createPayload(bufferedOutput)
                """
                message = [
                    "call",
                    "MyHandler",
                    [
                        json.dumps(payload) # we need to encode this again for Vim to like it
                    ]
                ]
                """
                message = { "parsed_data": payload }

                encoded = json.dumps(message)

                if thesocket is None:
                    print("No socket yet. Message would have been:")
                    print(encoded)
                else:
                    print(f"Sending {encoded}")
                    thesocket.sendall(encoded.encode('utf-8'))
            bufferedOutput = []
        else:
            l = l.replace("\t", "").replace("\r", "")
            bufferedOutput.append(l)
