#! /bin/bash

# see here for the idea:
# http://blog.jb55.com/post/29072842980/sending-commands-from-vim-to-a-separate-tmux-pane

# invoke with optional suffix (so that I could have several windows waiting for commands to be sent from vim

# then in vim, do something like:
# :silent execute '!echo "java Foo" > /tmp/vimCmds' | redraw!
# or better yet, map it:
# map <SOMEKEY> :silent execute '!echo "clear ; java Foo" > /tmp/vimCmds'<CR>:redraw!<CR>
#
# we need to be silent, or vim will dump us to console
# we need to redirect to the named pipe that the window running this script is watching
# we need to redraw! or vim ends up with a blank window.

# put it all together (even better if put it together with GNU Screen or tmux) and you can kick off
# commands without ever leaving vim. So for instance I could run tmux, split panes, run this 
# listenForVimCmds script in the right pane, map vim (presumably automatically in vimrc) to send 
# compile/run commands to this window, and then I can compile/run while still viewing source code

if [ -z $1 ]; then
	namedPipe="/tmp/vimCmds"
else
	namedPipe="/tmp/vimCmds${1}"
fi

echo "listening for commands over FIFO [${namedPipe}]..."

rm ${namedPipe}
mkfifo ${namedPipe}
while :; do bash < ${namedPipe} && echo "== OK =="; done
