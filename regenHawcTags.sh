#! /bin/bash

cd $HAWC_HOME
# find . -name "*.py" | grep -v "./target/" | grep -v "./unsynced/" | ctags -f .hawcTags -L -
find . -name "*.py" | ctags -f .hawcTags -L -
