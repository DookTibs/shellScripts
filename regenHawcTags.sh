#! /bin/bash

date
echo "building tags for HAWC codebase..."
cd $HAWC_HOME
# find . -name "*.py" | grep -v "./target/" | grep -v "./unsynced/" | ctags -f .hawcTags -L -
find . -name "*.py" | ctags --python-kinds=-i -f .hawcTags -L -

# little bit trickier. We build the tags file, but then we want to change the path of each reference
# from a relative one ("./matplotlib/whatever") to absolute ("/Users/tfeiler...virtualenvs...matplotlib/whatever")
date
echo "building tags for installed packages..."
# cd /Users/tfeiler/.virtualenvs/hawc2021/lib/python3.9/site-packages
cd /Users/tfeiler/.virtualenvs/hawc2023/lib/python3.11/site-packages
find . -name "*.py" | ctags --python-kinds=-i -f $HAWC_HOME/.hawcVirtualEnvInstalledPackagesTagsRelative -L -

date
echo "fixing absolute paths for package..."
cd $HAWC_HOME
# cat .hawcVirtualEnvInstalledPackagesTagsRelative | sed 's-\t\./-\t/Users/tfeiler/.virtualenvs/hawc2021/lib/python3.9/site\-packages/-' > .hawcVirtualEnvInstalledPackagesTags
cat .hawcVirtualEnvInstalledPackagesTagsRelative | sed 's-\t\./-\t/Users/tfeiler/.virtualenvs/hawc2023/lib/python3.11/site\-packages/-' > .hawcVirtualEnvInstalledPackagesTags
rm .hawcVirtualEnvInstalledPackagesTagsRelative
