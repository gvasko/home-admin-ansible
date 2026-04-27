#!/bin/bash

source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
	echo "ERROR: missing BASEDIR"
	exit 1
fi

NAME="$1"
IP="$2"
PORT="${3:-80}"

if [ -z $NAME ] || [ -z $IP ]; then
	echo "ERROR: missing argument"
	echo "Usage: test-access.sh <name> <ip-address>"
	exit 1
fi

FAILSTATE="$BASEDIR/statelog/$NAME-failed"

if nc -z $IP $PORT ; then
	if [ -f $FAILSTATE ]; then
		rm $FAILSTATE
		$BASEDIR/tools/admin-notify.sh "FIXED! $NAME is available again"
	fi
else
	if [ ! -f $FAILSTATE ]; then
		$BASEDIR/tools/admin-notify.sh "WARNING! $NAME is not available"
		touch $FAILSTATE
	fi
fi

