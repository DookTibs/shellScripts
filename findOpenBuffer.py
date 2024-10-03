#!/usr/bin/env python

import re, subprocess, sys

# give it a single name, e.g. 'findOpenBuffer.py "No Name"', 'findOpenBuffer.py .java', 'findOpenBuffer.py timesheet', etc.
# this will find all running Neovim instances. For each it will use Neovim's remote interface to check the
# open buffers. If it finds a match (simple string comparison; no wildcard/regex support for now), it will
# then figure out which tmux pane it's running in, and report back the info.
#
# No more having a file open in some rando pane somewhere that I can't find!

# dependencies  - lsof (seems stock OSX)
#               - tmux (duh)
#               - pstree (brew install pstree)


def pdebug(s):
    if False:
        print(s)

# do rough equivalent of this
# lsof -a -cnvim | tail --lines=+2 | awk '{ print $9 }' | grep nvim.38593 | sort | uniq
# this is gonna get us the process id and the neovim server address for every running neovim instance on our machine
def get_running_neovim_instances():
    pdebug("get_running neovim...")
    output = subprocess.check_output(['lsof', '-a', '-cnvim'])
    
    output = output.decode("utf-8")
    num_neovim_instances = 0
    neovim_instances = []
    for line in output.splitlines():
        if "nvim.38593" in line and "/private/var" not in line:
            # print(line)
            nvim_pid = re.sub(r"nvim *(.*) 38593.*", r"\1", line)
            nvim_server = re.sub(r".*(/var/folders.*)", r"\1", line)
            pdebug(f"\t{nvim_pid=} / {nvim_server=}")
            num_neovim_instances += 1
            neovim_instances.append({ "nvim_pid": nvim_pid, "nvim_server": nvim_server})

    pdebug(f"that's {num_neovim_instances} instances...")
    return neovim_instances

def get_all_tmux_panes():
    pdebug("get panes")
    output = subprocess.check_output([
                                        "tmux",
                                        "list-panes",
                                        #"-s", # just this session
                                        "-a", # every pane, every session
                                        "-F",
                                        '#{session_name}:#{window_index}(#{window_name}).#{pane_index}:::#{pane_pid}'# (cmd==#{pane_current_command})'
                                    ])

    output = output.decode("utf-8")
    tmux_panes = {}
    for line in output.splitlines():
        pdebug(line)
        chunks = line.split(":::")
        tmux_panes[chunks[1]] = chunks[0]

    return tmux_panes

def get_enclosing_pane_for_neovim_instance(neovim_instance, tmux_panes):
    neovim_pid = neovim_instance["nvim_pid"]

    output = subprocess.check_output(["pstree", "-p", neovim_pid])

    output = output.decode("utf-8")
    for line in output.splitlines():
        loop_pid = re.sub(r".*\= (\d*) .*", r"\1", line)
        if loop_pid in tmux_panes:
            match = tmux_panes[loop_pid]
            return match
        else:
            # print(f"{line} (no match for {loop_pid})")
            pass

def search_open_buffers_for_neovim_instance(neovim_instance, pattern):
    neovim_server = neovim_instance["nvim_server"]
    pdebug(f"check buffers on {neovim_server}")

    output = subprocess.check_output([
                                        "nvim",
                                        "--clean",
                                        "--headless",
                                        "--server",
                                        neovim_server,
                                        "--remote-expr",
                                        "execute('ls')"
                                    ])

    output = output.decode("utf-8")
    for line in output.splitlines():
        bufnum = re.sub(r" *(\d*) .*", r"\1", line)
        # filename = re.sub(r"nvim *(.*) 38593.*", r"\1", line)
        if bufnum.isdigit():
            filename = re.sub(r'.*"(.*)".*', r"\1", line)
            pdebug(f"\t[{bufnum=}], {filename=}")

            if pattern in filename.lower():
                yield (filename, bufnum)


# TODO - test with neovims not running in tmux, can we tell this?

if len(sys.argv) != 2:
    print(f"Usage: findOpenBuffer.py <file_search_pattern>")
    print(f"e.g. findOpenBuffer.py something.txt")
else:
    search_pattern = sys.argv[1]
    # print(f"Searching for '{search_pattern}'...")
    lowered_pattern = search_pattern.lower()

    pdebug(">>>>>>>>")
    neovim_instances = get_running_neovim_instances()
    pdebug(">>>>>>>>")
    tmux_panes = get_all_tmux_panes()
    pdebug(">>>>>>>>")
    num_matches = 0
    for ni in neovim_instances:
        for bufmatch_filename, bufmatch_bufnum in search_open_buffers_for_neovim_instance(ni, lowered_pattern):
            # print(f"found {bufmatch_filename} / {bufmatch_bufnum}...")
            pane = get_enclosing_pane_for_neovim_instance(ni, tmux_panes)
            # print(f"\tNeovim {ni["nvim_pid"]} (e.g. \":echo v:servername\") is running in pane {pane}")
            # print(f"'{bufmatch_filename}' found in NeoVim with PID {ni["nvim_pid"]} running in {pane}, buffer #{bufmatch_bufnum}")

            if pane is None:
                pane = "(None)"

            if num_matches == 0:
                # print("{:<60} {:<50} {:<10} {:<10}".format("[tmux pane]", "[filename]", "[buf#]", "[nvim pid]"))
                # print("" + ("-" * 140))
                print("{:^60} | {:^50} | {:^10} | {:^10}".format("[tmux pane]", "[filename]", "[buf#]", "[nvim pid]"))
                print(f'{"-" * 61}+{"-" * 52}+{"-" * 12}+{"-" * 12}')

            # print("{:<60} {:<50} {:<10} {:<10}".format(pane,bufmatch_filename,bufmatch_bufnum,ni["nvim_pid"]))
            print("{:<60} | {:<50} | {:^10} | {:^10}".format(pane,bufmatch_filename,bufmatch_bufnum,ni["nvim_pid"]))

            """
            if pane is None:
                pane = "(non-tmux nvim) has"
            else:
                pane = f"\"{pane}\" tmux running nvim with"

            print(f"\t{pane} file '{bufmatch_filename}' open in buffer #{bufmatch_bufnum} (nvim pid == {ni["nvim_pid"]})")
            """

            num_matches += 1

    if num_matches == 0:
        print(f"NO MATCHES FOUND FOR '{search_pattern}'!")
    else:
        print(f"\n(REMINDER: use vim command e.g. \":9bdelete\" to unload buffer #9)")
