#! /bin/bash

# how it works
# LS_DOC_BUCKET     S3 bucket to sync up with
# LS_DOC_DIR        local dir to watch
# (don't forget the semicolon after you set your variables! See https://unix.stackexchange.com/a/56449)
#
# fswatch -o (emit # of events, not files that changed)
#         -0 (separated emitted vals by NUL, not newline)
#
# xargs -0 (look for NUL separated events)
#       -n 1 (run command on every event)
#       -I {} (lets us use {} as a substitute for the emitted val; not actually in use)
#       aws.... (command to execute)
#
# put it all together and this is a command that will automatically sync your local document # directory with what's up on S3, every time you save any file in the tree!

if [ "$1" != "dev" ] && [ "$1" != "prod" ]; then
	echo "Usage: ./lsdocs_doc_syncer.sh [dev|prod]"
	exit 1
fi

LS_ASSETS_BUCKET="s3://litstream-$1-documentation-assets"
LS_ASSETS_DIR="/Users/38593/development/icf_dragon/src/lsdocs/___assets___/"

# echo "Getting latest assets from ${LS_ASSETS_BUCKET}..."
# aws s3 sync ${LS_ASSETS_BUCKET} ${LS_ASSETS_DIR}

echo "first push local git repo->S3..."
aws s3 sync --exclude "*" --include "*.png" --include "*.jpg" --include "_mov" $LS_ASSETS_DIR $LS_ASSETS_BUCKET

echo "Watching assets dir to upload changes; CTRL-C to stop..."
fswatch -o -0 $LS_ASSETS_DIR | xargs -0 -n 1 -I {} aws s3 sync --exclude "*" --include "*.png" --include "*.jpg" --include "_mov" $LS_ASSETS_DIR $LS_ASSETS_BUCKET                                                                     
