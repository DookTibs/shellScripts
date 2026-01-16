#!/bin/bash

echo "jsut a scratchpad right now; not a working script. Open it and see what's up..."
echo "(you probably just want to run findOpenBuffer.py which works!)"
exit 1

# right now I have all but the "figure out which..." piece working in PoC form...

# idea:
# takes a filename / pattern, e.g. "TIMESHEET.txt"
# finds all running Neovim sessions
# for each of this:
	# runs a remote command and gets all running buffers, looking for a match
	# if there's a match
		# figure out which tmux session:window.pane that Vim instance is running in, and print it out


# https://www.reddit.com/r/neovim/comments/w6fxhu/opened_files_in_neovim_from_the_command_line/
# this command appears to show all running Neovim instances for me...
lsof -a -cnvim | tail --lines=+2 | awk '{ print $9 }' | grep nvim.38593 | sort | uniq

# returns e.g.
# /private/var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/9VGtQf
# /private/var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/NkMdVj
# /private/var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/VMjCTx

# within an nvim session I can do:
# :echo v:servername
# prints e.g.
# /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/VMjCTx/nvim.35009.0

# THAT LINES UP:
# lsof:		/private/var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/VMjCTx
# nvecho:           /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/VMjCTx/nvim.35009.0

# nvim --server /tmp/nvim.pipe --remote-send 'cmd'

# this works! delete the current line. cool...
# https://www.reddit.com/r/neovim/comments/zc5p50/send_remote_command_silently/
# nvim --server /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/VMjCTx/nvim.35009.0 --remote-send 'dd'


# https://neovim.io/doc/user/remote.html
nvim --server /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/a9uitS/nvim.38939.0 --remote-send ':buffers'

# this works - run a command and get the data back into bash!
# get the pid of the vim process...do ":let x = getpid()" and ":echo x" to verify
nvim --clean --headless --server /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/gaZVHH/nvim.30300.0 --remote-expr "getpid()"

# e.g. 30300

# spit out parent processes -- I can compare the ancestors of 30300 with the output of
# the "show EVERY tmux pane" cmd below -- this will tell me which pane a given nvim
# instance is running in!
pstree -p 30300

# print the buffers
nvim --clean --headless --server /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/gaZVHH/nvim.30300.0 --remote-expr "execute('ls')"

# TODO - make a function that spits this all out at once

# getting full path will take some work. Is just filename enough, probably yes?

# everything above works and is promising. Stuff below is a work in progress;

# how can neovim get the current tmux info? 
nvim --server /var/folders/v3/3l2vwgxx6qq78gccfgg4q9m80000gp/T/nvim.38593/a9uitS/nvim.38939.0 --remote-send ':!tmux list-panes -s -F "look at this #{session_name} did it work"'

# show EVERY tmux pane, along with the pid of the program running there
# -s just for the session (nice for testing); -a for all (good for real!)
tmux list-panes -s -F "#{session_name}:#{window_index}(#{window_name}).#{pane_index} pid==#{pane_pid} (cmd==#{pane_current_command})"

# now how can I get the pid of a given Vim process? Could then tie that to v:servername

# https://stackoverflow.com/questions/25340314/is-there-a-way-to-get-the-active-pane-id-for-tmux-panes

