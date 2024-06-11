#!/bin/bash

# idea here is that I selectively copy certain things into the OneDrive dir, while keeping my
# work in the ~/development (or wherever). Cron this to run nightly or whatever.
#
# combined with "NEW WORK COMPUTER CHECKLIST" on my Google Docs and I should be able to come
# back from future computer crashes...

DESTINATION="/Users/tfeiler/OneDrive - ICF/personal_backups"

echo "running my personal backup script - copies data to ${DESTINATION} which gets backed up automatically."

# rsync -an --exclude cache/ src_folder/ target_folder/

echo "backing up shellscripts..."
mkdir -p "${DESTINATION}/development/shellScripts"
rsync -a /Users/tfeiler/development/shellScripts/ "$DESTINATION/development/shellScripts"

echo "backing up configurations..."
mkdir -p "${DESTINATION}/development/configurations"
rsync -a /Users/tfeiler/development/configurations/ "$DESTINATION/development/configurations"

echo "backing up miscellaneous config/etc...."
mkdir -p "${DESTINATION}/misc/_config"
rsync -a /Users/tfeiler/.config/ "$DESTINATION/misc/_config"
rsync /Users/tfeiler/.pgpass "$DESTINATION/misc/_pgpass"
mkdir -p "${DESTINATION}/misc/_ssh"
rsync -a /Users/tfeiler/.ssh/ "$DESTINATION/misc/_ssh"
mkdir -p "${DESTINATION}/misc/_aws"
rsync -a /Users/tfeiler/.aws/ "$DESTINATION/misc/_aws"

echo "backing up Documents..."
mkdir -p "${DESTINATION}/Documents"
rsync -a --exclude rules/ /Users/tfeiler/Documents/ "$DESTINATION/Documents"

echo "backing up litstream..."
mkdir -p "${DESTINATION}/development/icf_dragon"
rsync -a --exclude db_backup/backups/ --exclude target/ /Users/tfeiler/development/icf_dragon/ "$DESTINATION/development/icf_dragon"

# TODO - more development
