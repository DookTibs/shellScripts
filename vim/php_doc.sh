#!/bin/sh

# DEPRECATED - now use the vimKeywordLookup script

# this script takes a single argument and attempts to look up a function with that name on 
# php.net. it's most useful when used in conjunction with vim's shift-K (keyword) command, which, when
# editing php, I have mapped to this script. Basically put your cursor over a keyword like "strtoupper" and
# hit shift K, and you'll get documentation about it from php.net!
#
# for non-PHP files, the K vim command runs "man" but it could be easily extended for other languages.

# set these otherwise sed can throw some odd errors
LANG=C
LC_ALL=C

FN=`echo $1 | sed 's/_/-/g'`
echo ********************** $FN **********************

pageToFetch="http://www.php.net/manual/en/print/function.$FN.php"
# lynx -dump -nolist http://www.php.net/manual/en/print/function.$FN.php | sed -n /^$1/,/^.*User\ Contributed\ Notes/p | grep -v ‘User\ Contributed\ Notes’

# sed by default can't search multilines. This basically builds up the
# hold buffer to contain all the output, and then we can run sed on 
# the entire text

lynx -dump -nolist $pageToFetch | sed -n '
# if the first line copy the pattern to the hold buffer
1h
# if not the first line then append the pattern to the hold buffer
1!H
# if the last line then ...
$ {
        # copy from the hold to the pattern buffer
        g
        # do the search and replace
	
		# this one strips out everything leading up to the docs we care about
        s/.*Edit Report a Bug\n//g

		# this one strips out the user contributed notes and everything after
        s/User Contributed Notes.*//g

        # we suppressed output up above; now print it out
        p
}
' | less
