#!/bin/bash
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi


FREE_GB=$(df -BG --output=avail "$CAM_STORAGE_MNT/" | tail -1 | tr -dc '0-9')

if [ "$FREE_GB" -lt "100" ]; then
	$BASEDIR/tools/admin-notify.sh "WARNING! NVR disk below 100GB"
elif [ "$FREE_GB" -lt "200" ]; then
        $BASEDIR/tools/admin-notify.sh "WARNING! NVR disk below 200GB"
elif [ "$FREE_GB" -lt "400" ]; then
        $BASEDIR/tools/admin-notify.sh "WARNING! NVR disk below 400GB"
fi

# testing
#if [ "$FREE_GB" -lt "1000" ]; then
#        $BASEDIR/tools/admin-notify.sh "WARNING! NVR disk below 1000GB"
#fi

