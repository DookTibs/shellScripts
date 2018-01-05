#!/bin/bash
tmux select-pane -t 0

tmux send-keys -t 2 "vi prod_web_b/catalina.out" Enter
tmux send-keys -t 1 "vi prod_worker_a/catalina.out" Enter
tmux send-keys -t 3 "vi prod_worker_b/catalina.out" Enter

tmux send-keys -t 0 "vi prod_web_a/catalina.out" Enter
