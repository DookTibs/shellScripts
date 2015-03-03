#! /bin/bash

if [ -z "${1}" ]; then
	area="ventnorTfeilerReason"
else
	area="${1}";
fi

# can't get find/ctags to work quite right over symbolic links like we have in a reason install...
# cd ~/remotes/wsgTfeilerReason/html
# find -L . -name "*.php" | ctags -f phpTags -L -

date
# echo "generating tags for test reason installation"
# cd ~/remotes/wsgTfeilerReasonCore/
# find reason_package_20140404 -name "*.php" | ctags -f phpTags -L -

echo "generating tags for ventnor reason installation mounted on $area"
# cd ~/remotes/ventnorTfeilerReason/
cd ~/remotes/${area}/
find . -name "*.php" | ctags -f phpTags -L -

date
echo "done!"
