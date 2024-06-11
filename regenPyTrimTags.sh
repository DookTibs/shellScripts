#! /bin/bash

cd ~/development/trim-builder/
# find . -name "*.php" | grep "./reason_package" | ctags -f .php_tags -L -
find . -name "*.py" | grep -v "./target/" | grep -v "./unsynced/" | ctags -f .trimTags -L -
