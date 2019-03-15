#! /bin/bash
echo -n "Regenerating ctags for DRAGON Online..."
cd $DRAGON_HOME/src/main/java/
ctags -f .dragonOnlineJavaTags -R .
echo "done!"

echo -n "Regenerating cscope db..."
cd $DRAGON_HOME/src/main/java/

# needed for cygwin only
# find "$PWD"/ -name "*.java" > tempFileNotFixed
# sed 's-/cygdrive/c/-c:/-' tempFileNotFixed > tempFile

# osx version
find "$PWD"/ -name "*.java" > tempFile

gtags -f tempFile
rm tempFile*

echo "done!"
