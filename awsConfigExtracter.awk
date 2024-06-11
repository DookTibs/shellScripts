# script I use for simplifying AWS SSO login stuff...I want to just remember
# the [sso-session x] and use that in scripts/functions (like my aws_sso_login
# function in ~/development/configurations/bash/functions.bash). This script
# takes a nice name like "litstream_staging_admin_sso" and looks through
# ~/.aws/config for a profile that has that as it's sso_session. We could
# conceivably extend this to do other things, hence the generic name and the 
# fact you pass in a target_config_field (even though only one works at the moment!)
#
# Usage is like:
#
# cat  ~/.aws/config | awk -v target_config_field="profile_name" -v target_aws_session="litstream_staging_admin_sso" -f ~/development/shellScripts/awsConfigExtracter.awk
#
# this will return 0 and print out the value if it works, or return 1 and print out an
# error if it didn't.

BEGIN {
    # we are just using awk to process whole lines; we don't want to split
    # so we set FS to some garbage string we won't actually ever encounter
    FS = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	# IGNORECASE=1

	currentProfile = ""
	finalOutput = ""
}

match($1, /^\[profile (.*)\]/, x) {
	currentProfile = x[1]
}

match($1, /^sso_session.*= *(.*)/, x) {
	if (target_config_field == "profile_name" && x[1] == target_aws_session) {
		# print "found sso_session: " x[1] " (" currentProfile ")"
		finalOutput = currentProfile
		exit 0
	}
}

END {
	if (finalOutput == "") {
		print "could not find " target_config_field " for session " target_aws_session
		exit 1
	} else {
		print finalOutput
	}
}
