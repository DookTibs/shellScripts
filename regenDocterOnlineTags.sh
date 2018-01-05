#! /bin/bash

cd ~/development/docter_online/
# find . -name "*.php" | grep "./reason_package" | ctags -f .php_tags -L -
find . -name "*.py" | grep -v "./target/" | grep -v "./unsynced/" | ctags -f .docterOnlineTags -L -
