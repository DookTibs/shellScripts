#! /bin/bash

echo "Generating exuberant ctags files for CP asset pipeline actionscript code..."

cd ${BACON}
find . -name "*.as" | ctags -f actionscriptTags -L -
# find . -name "*.py" | ctags -f pythonTags -L -

echo "done!"
