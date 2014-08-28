#!/bin/bash
# see http://stackoverflow.com/questions/1220309/git-difftool-open-all-diff-files-immediately-not-in-serial
# and http://blog.codefarm.co.nz/2009/08/git-diff-and-difftool-open-all-files.html
#
# Now that I've got BeyondCompare4 on OSX, I want to do my git diffing with all files in tabs, instead of
# sequentially as git does by default. This script (and an alias in my ~/.gitconfig) let me do it
# by executing "git bcdiff"
#
# still could be better - I'd rather have directory structure to work with. But "git difftool --dir-diff"
# doesn't work yet on OSX? see http://www.scootersoftware.com/vbulletin/showthread.php?t=12329&highlight=--dir-diff
#
# another possibility -- copy the files we are comparing against to their own temp dir and diff against that.
#
#
git diff --name-only "$@" | while read filename; do
    git difftool -t bc3 "$@" --no-prompt "$filename" &
done
