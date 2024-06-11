#! /bin/bash


# on OSX I do:
# 1. "brew install global" -- this installs gtags
# 2. "brew unlink ctags" (maybe needed, not sure)
# 3. "brew install --HEAD universal-ctags/universal-ctags/universal-ctags" # this installs universal ctags




echo -n "Regenerating ctags for DRAGON Online..."
cd $DRAGON_HOME/src/main/java/
ctags -f .dragonOnlineJavaTags -R .
echo "done!"

# 202208 - not sure what this part does anymore?!?!?
if [ 1 -eq 2 ]; then
	echo -n "Regenerating cscope db..."
	cd $DRAGON_HOME/src/main/java/

	# needed for cygwin only
	# find "$PWD"/ -name "*.java" > tempFileNotFixed
	# sed 's-/cygdrive/c/-c:/-' tempFileNotFixed > tempFile

	# osx version
	find "$PWD"/ -name "*.java" > tempFile

	gtags -f tempFile
	rm tempFile*
fi

echo "done!"
