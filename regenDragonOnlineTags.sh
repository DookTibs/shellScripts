#! /bin/bash
echo -n "Regenerating ctags for DRAGON Online..."
cd /cygdrive/c/Users/38593/workspace/icf_dragon/src/main/java/
ctags -f .dragonOnlineJavaTags -R .
echo "done!"

echo -n "Regenerating cscope db..."
cd /cygdrive/c/Users/38593/workspace/icf_dragon/src/main/java/

find "$PWD"/ -name "*.java" > tempFileNotFixed
sed 's-/cygdrive/c/-c:/-' tempFileNotFixed > tempFile
gtags -f tempFile
rm tempFile*

echo "done!"
