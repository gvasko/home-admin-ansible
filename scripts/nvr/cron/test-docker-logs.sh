#!/bin/bash

source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi


FAILSTATE="$BASEDIR/statelog/frigate-failed"
FRIGATE_ERRORS=$(docker container logs frigate --since 1h 2>&1 | grep -E "\[error\]|Too many unprocessed recording segments" | tail -3)

if [ -z "$FRIGATE_ERRORS" ] ; then
	if [ -f $FAILSTATE ]; then
		rm $FAILSTATE
		$BASEDIR/tools/admin-notify.sh "FIXED! Frigate is OK"
	fi
else
	$BASEDIR/tools/admin-notify.sh "WARNING! Frigate errors: $FRIGATE_ERRORS"
	if [ ! -f $FAILSTATE ]; then
		touch $FAILSTATE
	fi
fi



