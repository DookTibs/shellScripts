#!/bin/bash

# -T so that we don't attempt TTY creation; suppresses a warning message
ssh -T -2 tfeiler@ventnor.its.carleton.edu << EOF
	cd /usr/local/webapps/branches/slote-apps/reason_package/reason_4.0/lib/core/scripts/developer_tools/
	/usr/local/wsg/php5/bin/php -d include_path=/usr/local/webapps/branches/slote-apps/reason_package/ find_old_policies.php
EOF
