#!/bin/bash

source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

LOGFILE="/var/log/cam-upload.log"
START_DATE=$(date)

echo "START UPLOAD: $START_DATE" >> $LOGFILE

if pgrep -x "azcopy" > /dev/null
then
    echo "AzCopy is already running. Exiting." >> $LOGFILE
    exit 1
fi

export AZCOPY_CONCURRENCY_VALUE=1

UPLOAD_MBPS=50

TIME_AGO=$(date --date='5 minutes ago' --iso-8601=seconds)

#SRC_DIR=$LOCAL_CAM_STORAGE_DIR
#DEST_DIR=$REMOTE_CAM_STORAGE_DIR

SRC_DIR=$LOCAL_CAM_DETECTOR_DIR
DEST_DIR=$REMOTE_CAM_DETECTOR_DIR

ionice -c 3 azcopy copy "$SRC_DIR/*" "$DEST_DIR/?$REMOTE_CAM_STORAGE_SAS" --recursive=true --cap-mbps $UPLOAD_MBPS --overwrite=false --include-after="$TIME_AGO" >> $LOGFILE 2>&1
azcopyStatus=$?

if [ $rsyncStatus -ne 0 ]; then
    echo "azcopy error: $azcopyStatus" >> "$LOGFILE"
    $BASEDIR/tools/admin-notify.sh "ERROR! Camera upload azcopy error: $azcopyStatus"
fi

END_DATE=$(date)

echo "FINISH UPLOAD: $END_DATE" >> $LOGFILE
START_SEC=$(date -d "$START_DATE" +%s)
END_SEC=$(date -d "$END_DATE" +%s)
DIFF_SEC=$((END_SEC - START_SEC))
echo "UPLOAD TOOK $DIFF_SEC seconds / $END_DATE" >> $LOGFILE

