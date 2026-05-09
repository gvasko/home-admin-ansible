#!/bin/bash
# MANAGED BY ANSIBLE
{
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi


FAILSTATE="$BASEDIR/statelog/syslog-failed"
SYSLOG_ERRORS=$(journalctl --since "10 minute ago" 2>&1 | grep -E "\[error\]|\[failed\]" | tail -3)

if [ -z "$SYSLOG_ERRORS" ] ; then
	if [ -f $FAILSTATE ]; then
		rm $FAILSTATE
		$BASEDIR/tools/admin-notify.sh "FIXED! Syslog is OK"
	fi
else
	$BASEDIR/tools/admin-notify.sh "WARNING! Syslog errors: $SYSLOG_ERRORS"
	if [ ! -f $FAILSTATE ]; then
		touch $FAILSTATE
	fi
fi

}
