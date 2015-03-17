#! /bin/bash

username=`whoami`
clampDevServer="mitre.clamp-it.org"

if [ -z "${1}" ]; then
	echo "Usage: regenClampTags <DRIFT_INSTANCE_NAME>"
	exit 1
else
	driftInstance="${1}";
fi
tagsFilename="tags_$driftInstance"

echo "generating tags for Mitre moodle instance '$driftInstance' (`date`)"

tgz="ctagsSnapshot_$driftInstance".tgz

# 1. ssh up to mitre and tar-zip the relevant bits of the installation
echo "##### Connecting to mitre; creating compressed archive of relevant source... (`date`)"
cmd="cd moodles ; tar czf $tgz --exclude .git --exclude \"*.log\" $driftInstance/"
ssh $username@${clampDevServer} $cmd

echo "##### Copying compressed archive from mitre to my machine (`date`)"
tempdir="/tmp/ctagsTemp_$driftInstance"
mkdir $tempdir
scp $username@${clampDevServer}:~/moodles/$tgz $tempdir/

echo "##### Extracting archive on my machine (`date`)"
cd $tempdir
tar xf $tgz

echo "##### Finding php files and running ctags... (`date`)"
find . -name "*.php" | ctags -f $tagsFilename -L -

echo "##### Copying tags file back up to mitre... (`date`)"
scp $tempdir/$tagsFilename $username@${clampDevServer}:~/moodles/

echo "##### Cleanup... (`date`)"
cmd="rm moodles/$tgz"
ssh $username@${clampDevServer} $cmd
rm -rf $tempdir

echo "##### Done! (`date`)"
exit














# this was the old approach this script took


# cd ~/remotes/mitreClampHome/showHideCourse_20150305
cd /Users/tfeiler/development/mitreTemp/showHideCourse_20150305

# this is how moodle suggests you generate ctags (http://docs.moodle.org/dev/ctags)
#ctags -R --languages=php --exclude="CVS" --php-kinds=f \
	#--regex-PHP='/abstract class ([^ ]*)/\1/c/' \
	#--regex-PHP='/interface ([^ ]*)/\1/c/' \
	#--regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'

# when I do it this way, I get a tags file only about 25% of the size of the one below - and
# I don't have stuff like consts/defines. Maybe revisit this but for now I think this is the way to go.

find . -name "*.php" | ctags -f tjfTags -L -

# mitre is so slow, doing this over ssh-mounted filesystem was taking upwards of 30 minutes (time this later?)
# let's rewrite this to run the following command over ssh (older/crappier version of ctags so 
# need to work it slightly differently
# find . -name "*.php" -exec ctags {} -a -o tjfTags \;

# odd results. Another thought:
# 1. tgz up the important bits
#		(ON MITRE) tar cvzf snapshot.tgz --exclude .git --exclude "*.log" showHideCourse_20150305/
# 2. scp that file down to my deskop
# 3. extract it somewhere temporary (tar xvf snapshot.tgz)	
# 4. run the find / ctags command on it
# 5. scp the file back up to mitre


date
echo "done!"
