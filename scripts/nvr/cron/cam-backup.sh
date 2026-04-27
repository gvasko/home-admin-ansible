#!/bin/bash
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

LOGFILE="/var/log/cam-backup.log"

echo -e "\n#############################" >> "$LOGFILE"
echo "Cam storage sync starting..." >> "$LOGFILE"
date >> "$LOGFILE"

echo "RSYNC_CAM_SOURCE: $RSYNC_CAM_SOURCE" >> "$LOGFILE"
echo "RSYNC_CAM_DEST: $RSYNC_CAM_DEST" >> "$LOGFILE"

# Exit if an rsync process is already running
if pgrep -x rsync >/dev/null; then
    echo "rsync is already running, exiting." >> "$LOGFILE"
    exit 0
fi

# Ensure backup mount is present
if ! mountpoint -q "$CAM_BACKUP_MNT"; then
    echo "Backup mount not found, exiting." >> "$LOGFILE"
    $BASEDIR/tools/admin-notify.sh "ERROR! Local backup error: mount not found."
    exit 1
fi

RATE_LIMIT_KBPS=20000

ionice -c 3 rsync --inplace --size-only -avh --delete --bwlimit=$RATE_LIMIT_KBPS "$RSYNC_CAM_SOURCE" "$RSYNC_CAM_DEST" >> "$LOGFILE" 2>&1
rsyncStatus=$?

if [ $rsyncStatus -ne 0 ]; then
    echo "RSync error: $rsyncStatus" >> "$LOGFILE"
    $BASEDIR/tools/admin-notify.sh "ERROR! Local backup rsync error: $rsyncStatus"
fi

date >> "$LOGFILE"
echo "Cam storage sync finished." >> "$LOGFILE"

