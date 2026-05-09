#!/bin/bash
# MANAGED BY ANSIBLE
{
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
	echo "ERROR: missing BASEDIR"
	exit 1
fi

NAME="$1"
URL="$2"

if [ -z $NAME ] || [ -z $URL ]; then
	echo "ERROR: missing argument"
	echo "Usage: test-access.sh <name> <url>"
	exit 1
fi

FAILSTATE="$BASEDIR/statelog/$NAME-health-failed"

if curl -sSf --max-time 5 $URL ; then
	if [ -f $FAILSTATE ]; then
		rm $FAILSTATE
		$BASEDIR/tools/admin-notify.sh "FIXED! $NAME is answering again"
	fi
else
	if [ ! -f $FAILSTATE ]; then
		$BASEDIR/tools/admin-notify.sh "WARNING! $NAME is not answering"
		touch $FAILSTATE
	fi
fi

}
