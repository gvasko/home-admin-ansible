#!/bin/bash
# MANAGED BY ANSIBLE
{
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

$BASEDIR/tools/admin-notify.sh "INFO RouterPi started"

/usr/bin/python /home/admin/home-admin/routerpi/cron/set-fan-speed.py 40


}