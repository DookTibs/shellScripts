#! /bin/bash

echo "Generating exuberant ctags files for relevant Club Penguin source directories..."

subdirs=(
	"cp/trunk"
	"externalLib/trunk/src"
	"sharedLib/trunk/src"
)


for subdir in ${subdirs[*]}
do
	echo ">>>>> Generating tags for [${subdir}]..."
	cd ${CLUBPENGUIN}

	cd ${subdir}
	ctags -R .
done

echo "done!"
