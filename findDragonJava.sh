#!/bin/bash
cd /cygdrive/c/Users/38593/workspace/icf_dragon/src/main/java/
find . -name "*.java" -exec grep -l "$1" {} \;
# ag -li "$1"
cd -
