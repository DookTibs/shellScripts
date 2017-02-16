#! /bin/bash

if [ -z "${1}" ]; then
	# area="ventnorTfeilerReason"
	area="${REASON_MOUNT_NAME}"
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

if [ "${area}" = "vagrant" ]; then
	echo "generating tags for new vagrant test rig!"
	# cd ~/development/reason/carl-web-reason/
	cd ~/development/carleton/carleton.edu/
	find . -name "*.php" | grep "./reason_package" | ctags -f .php_tags -L -
else
	echo "generating tags for reason installation mounted on $area"
	# cd ~/remotes/ventnorTfeilerReason/
	cd ~/remotes/${area}/
	find . -name "*.php" | ctags -f .php_tags -L -
fi

date
echo "done!"
