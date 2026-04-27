#!/bin/bash
source "$HOME/.home-automation.secrets"

if [ -z $BASEDIR ]; then
        echo "ERROR: missing BASEDIR"
        exit 1
fi

$BASEDIR/tools/test-access.sh cam-front-door $CAM_FRONT_DOOR_IP
$BASEDIR/tools/test-access.sh cam-front-stairs $CAM_FRONT_STAIRS_IP
$BASEDIR/tools/test-access.sh cam-front-gate $CAM_FRONT_GATE_IP
$BASEDIR/tools/test-access.sh cam-yard $CAM_YARD_IP
$BASEDIR/tools/test-access.sh cam-garden $CAM_GARDEN_IP


