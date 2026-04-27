#!/bin/bash
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

echo "RSYNC_CAM_SOURCE: $RSYNC_CAM_SOURCE"
echo "RSYNC_CAM_DEST: $RSYNC_CAM_DEST"

# Ensure backup mount is present
if ! mountpoint -q "$CAM_BACKUP_MNT"; then
    echo "Backup mount not found, exiting." >> "$LOGFILE"
    $BASEDIR/tools/admin-notify.sh "ERROR! Local backup test error: mount not found."
    exit 1
fi

echo "Sleeping 15sec"
sleep 15

RATE_LIMIT_KBPS=20000

NUMBER_OF_CHANGES=$(ionice -c 3 rsync --dry-run --stats --inplace --size-only -avh --delete --bwlimit=$RATE_LIMIT_KBPS "$RSYNC_CAM_SOURCE" "$RSYNC_CAM_DEST" | grep 'Number of regular files transferred')


echo "$NUMBER_OF_CHANGES"

MESSAGE=${NUMBER_OF_CHANGES/Number of regular files transferred/Backup difference}

$BASEDIR/tools/silent-notify.sh "INFO: $MESSAGE"

