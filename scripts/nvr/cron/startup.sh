#!/bin/bash
# MANAGED BY ANSIBLE
{
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

$BASEDIR/tools/admin-notify.sh "INFO NVR started"

}