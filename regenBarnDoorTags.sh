#! /bin/bash

echo "generating tags for barndoors"
cd ~/development/barnDoorTests
find . -name "*.coffee" | ctags -f coffeeTags -L -
