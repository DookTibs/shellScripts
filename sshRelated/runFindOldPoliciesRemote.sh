#!/bin/bash

ssh -T -2 tfeiler@ventnor.its.carleton.edu << EOF
	cd /usr/local/webapps/branches/slote-apps/reason_package/reason_4.0/lib/local/scripts/reminders/
	/usr/local/wsg/php5/bin/php -d include_path=/usr/local/webapps/branches/slote-apps/reason_package/ find_old_policies.php -tt "2 years ago" -aa "tfeiler" -d "tfeiler" -s
EOF
# ssh -2 tfeiler@ventnor.its.carleton.edu /usr/local/wsg/php5/bin/php -d include_path=/usr/local/webapps/branches/slote-apps/reason_package/ /usr/local/webapps/branches/slote-apps/reason_package/reason_4.0/lib/core/scripts/developer_tools/find_old_policies.php
