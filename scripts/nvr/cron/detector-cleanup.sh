#!/bin/bash

source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

echo 'Starting daily cleanup...'
find "$LOCAL_CAM_DETECTOR_DIR" -name 'event_*.mp4' -type f -mtime +1 -delete
echo 'Cleanup complete.'

