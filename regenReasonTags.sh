#! /bin/bash

# can't get find/ctags to work quite right over symbolic links like we have in a reason install...
# cd ~/remotes/wsgTfeilerReason/html
# find -L . -name "*.php" | ctags -f phpTags -L -

date
# echo "generating tags for test reason installation"
# cd ~/remotes/wsgTfeilerReasonCore/
# find reason_package_20140404 -name "*.php" | ctags -f phpTags -L -

echo "generating tags for ventnor slote-apps reason installation"
cd ~/remotes/ventnorTfeilerReason/
# cd ~/remotes/ventnorMryanReason/
find . -name "*.php" | ctags -f phpTags -L -

date
echo "done!"
