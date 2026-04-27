#!/bin/bash

# Use "mqtt" as host because they are in the same docker network
MQTT_HOST="mqtt"
FRIGATE_HOST="frigate"
SAVE_DIR="/clips"

mkdir -p "$SAVE_DIR"

# Wait for MQTT to be ready
sleep 5

mosquitto_sub -h "$MQTT_HOST" -t "frigate/events" | while read -r PAYLOAD; do
    TYPE=$(echo "$PAYLOAD" | jq -r '.type')
    POS_CHANGES=$(echo "$PAYLOAD" | jq -r '.after.position_changes')
    LABEL=$(echo "$PAYLOAD" | jq -r '.after.label')
    ZONES=$(echo "$PAYLOAD" | jq -r '.after.current_zones')
    STAT=$(echo "$PAYLOAD" | jq -r '.after.stationary')
    CAMERA=$(echo "$PAYLOAD" | jq -r '.after.camera')
    EVENT_ID=$(echo "$PAYLOAD" | jq -r '.after.id')

    if [[ "$LABEL" == "person" ]]; then
        PUSHOVER_MSG="$CAMERA $LABEL $TYPE $EVENT_ID"
	if [[ "$ZONES" != "[]" ]]; then
            PUSHOVER_MSG="$PUSHOVER_MSG in $ZONES"
	fi
	echo "Pushover message: $PUSHOVER_MSG"
	if [[ "$NOTIFICATION_ENABLED" == "true" ]] && [[ $TYPE == "new" ]]; then
            curl -s --form-string "token=$PUSHOVER_TOKEN" --form-string "user=$PUSHOVER_USERKEY" --form-string "message=$PUSHOVER_MSG" https://api.pushover.net/1/messages.json
	fi
    fi

    if [[ "$LABEL" =~ ^(person|car|bus|bicycle|motorcycle)$ ]] && [[ "$TYPE" == "end" ]] && [[ "$POS_CHANGES" -gt 0 ]]; then
	{
	    EVENT_ID=$(echo "$PAYLOAD" | jq -r '.after.id')
	    FILE_NAME="event_${EVENT_ID}_${CAMERA}_${LABEL}.mp4"

            MAX_RETRIES=3
            RETRY_COUNT=0
            SUCCESS=false
            WAIT_TIME=10 # Seconds to wait between attempts

            while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
                RETRY_COUNT=$((RETRY_COUNT + 1))
                
                echo "Attempt $RETRY_COUNT: Waiting ${WAIT_TIME}s to download $EVENT_ID..."
                sleep $WAIT_TIME
                
                if curl -sf "http://$FRIGATE_HOST:5000/api/events/$EVENT_ID/clip.mp4?padding=5" -o "$SAVE_DIR/$FILE_NAME"; then
                    echo "Success: Saved clip for $EVENT_ID on attempt $RETRY_COUNT: $FILE_NAME - stationary: $STAT."
                    SUCCESS=true
                    break
                else
                    echo "Attempt $RETRY_COUNT failed for $EVENT_ID."
                    # Increase wait time for the next attempt (exponential backoff)
                    WAIT_TIME=$((WAIT_TIME + 10)) 
                fi
            done

            if [ "$SUCCESS" = false ]; then
                echo "Final Error: Could not download clip for $EVENT_ID after $MAX_RETRIES attempts: $FILE_NAME - stationary: $STAT."
            fi
	} &
    fi
done

