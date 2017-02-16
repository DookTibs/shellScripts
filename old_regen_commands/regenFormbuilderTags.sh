#! /bin/bash

echo "generating tags for formbuilder"
cd ~/development/jsloteFormBuilder/formbuilder/
find . -name "*.coffee" | ctags -f coffeeTags -L -

cd ~/development/jsloteFormBuilder/formbuilder-rsn/
find . -name "*.coffee" | ctags -f coffeeTags -L -
