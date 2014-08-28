#! /bin/bash
# curl -I -H "Pragma: akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamche-key, akamai-x-get-extracted-values, akamai-x-get-nonces, akamai-x-get-ssl-client-session-id, akamai-x-get-true-cache-key, akamai-x-serial-no" --write-out %{http_code} --silent --output /dev/null "http://media1.clubpenguin.com/mobile/cp-mobile-ui/en_US/deploy/metaplace/ipad2/assets/catalog/igloo/igloo_page02_bg.png"

# foo=$(curl -I -H "Pragma: akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamche-key, akamai-x-get-extracted-values, akamai-x-get-nonces, akamai-x-get-ssl-client-session-id, akamai-x-get-true-cache-key, akamai-x-serial-no" --write-out %{http_code} --silent --output /dev/null "http://media1.clubpenguin.com/mobile/cp-mobile-ui/en_US/deploy/metaplace/ipad2/assets/catalog/igloo/igloo_page02_bg.png")

# cmd="curl -I --write-out %{http_code} --silent --output /dev/null http://media1.clubpenguin.com/mobile/cp-mobile-ui/en_US/deploy/metaplace/ipad2/assets/catalog/igloo/igloo_page02_bg.png"

# PROBLEM
# cmd="curl -I --write-out %{http_code} --silent --output /dev/null -H \"Pragma:akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-check-cacheable,akamche-key,akamai-x-get-extracted-values,akamai-x-get-nonces,akamai-x-get-ssl-client-session-id,akamai-x-get-true-cache-key,akamai-x-serial-no\" http://media1.clubpenguin.com/mobile/cp-mobile-ui/en_US/deploy/metaplace/ipad2/assets/catalog/igloo/igloo_page02_bg.png"

# echo "cmd is [${cmd}]"
# foo=$($cmd)
# echo "foo is [${foo}]"

# foo=$(wc -l smallList.txt)
# echo "lines=[$foo]"

# for word in $foo; do
	# echo "toke=[$word]"
# done

# tokens=( $foo )
# echo "first token is [${tokens[0]}]"

filename="tempError_301.tmp"
echo "filename [$filename]"
[[ $filename =~ tempError_(.*)\.tmp ]]
code=${BASH_REMATCH[1]}
echo "code is [$code]"
