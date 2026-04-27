#!/bin/bash
#

source "$HOME/.home-automation.secrets"

curl -s --form-string "token=$PUSHOVER_SILENT_ADMIN_TOKEN" --form-string "user=$PUSHOVER_USERKEY" --form-string "message=$1" https://api.pushover.net/1/messages.json

