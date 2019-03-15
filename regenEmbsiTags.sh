#! /bin/bash

cd ~/development/uncertainty/flask/
find . -name "*.py" | grep -v "./target/" | grep -v "./unsynced/" | ctags -f .embsiTags -L -
