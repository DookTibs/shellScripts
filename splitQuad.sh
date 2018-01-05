#!/bin/bash
clear
tmux clear-history

tmux split-window -h -c "#{pane_current_path}"
tmux split-window -v -c "#{pane_current_path}"
tmux select-pane -t 0
tmux split-window -v -c "#{pane_current_path}"
tmux select-pane -t 0
