#! /bin/bash

date

echo "generating tags for wsg omeka test instance"
cd ~/remotes/wsgOmeka/

find . -name "*.php" | ctags -f tags -L -

date
echo "done!"
