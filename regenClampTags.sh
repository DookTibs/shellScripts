#! /bin/bash

date
# echo "generating tags for test reason installation"
# cd ~/remotes/wsgTfeilerReasonCore/
# find reason_package_20140404 -name "*.php" | ctags -f phpTags -L -

echo "generating tags for moodle hack/doc"
cd ~/remotes/mitreClampHome/hello1

# this is how moodle suggests you generate ctags (http://docs.moodle.org/dev/ctags)
#ctags -R --languages=php --exclude="CVS" --php-kinds=f \
	#--regex-PHP='/abstract class ([^ ]*)/\1/c/' \
	#--regex-PHP='/interface ([^ ]*)/\1/c/' \
	#--regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'

# when I do it this way, I get a tags file only about 25% of the size of the one below - and
# I don't have stuff like consts/defines. Maybe revisit this but for now I think this is the way to go.

find . -name "*.php" | ctags -f tags -L -


date
echo "done!"
