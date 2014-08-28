#!/bin/bash
# reads data from stdin and filters out lines containing node_modules, bower_components, .git, etc. that
# I'm unlikely to be interested. Examples:

# find all directories in my current tree
# find . -type d | smartFilter.sh
#
# find all xml files...
# find . -name "*.xml" | smartFilter.sh


inputData="$(</dev/stdin)"

echo "${inputData}" | grep -v node_modules | grep -v bower_components | grep -v .git
