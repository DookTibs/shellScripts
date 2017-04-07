#! /bin/bash
echo -n "Regenerating tags for DRAGON Online..."
cd /cygdrive/c/Users/38593/workspace/icf_dragon/src/main/java/
ctags -f .dragonOnlineJavaTags -R .
echo "done!"
