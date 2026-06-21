#!/bin/bash
# MANAGED BY ANSIBLE

# Use "mqtt" as host because they are in the same docker network
MQTT_HOST="mqtt"
FRIGATE_HOST="frigate"
SAVE_DIR="/clips"
CACHE_DIR="$SAVE_DIR/cache"

mkdir -p "$SAVE_DIR"
mkdir -p "$CACHE_DIR"

# Wait for MQTT to be ready
sleep 5

mosquitto_sub -h "$MQTT_HOST" -t "frigate/events" | while read -r PAYLOAD; do
    TYPE=$(echo "$PAYLOAD" | jq -r '.type')
    POS_CHANGES=$(echo "$PAYLOAD" | jq -r '.after.position_changes')
    LABEL=$(echo "$PAYLOAD" | jq -r '.after.label')
    ZONES=$(echo "$PAYLOAD" | jq -c -r '.after.current_zones')
    STAT=$(echo "$PAYLOAD" | jq -r '.after.stationary')
    CAMERA=$(echo "$PAYLOAD" | jq -r '.after.camera' | sed 's/_/-/g')
    EVENT_ID=$(echo "$PAYLOAD" | jq -r '.after.id')
    seconds=$(echo "$EVENT_ID" | cut -d'.' -f1)
    suffix=$(echo "$EVENT_ID" | cut -d'-' -f2)
    inverse_seconds=$((3000000000 - seconds))
    padded_inverse=$(printf "%011d" "$inverse_seconds")
    REVERSE_ID="${padded_inverse}-${suffix}"
    START_TIME=$(echo "$PAYLOAD" | jq -r '.after.start_time')
    END_TIME=$(echo "$PAYLOAD" | jq -r '.after.end_time')

    # if [[ "$LABEL" == "person" ]]; then
    #     PUSHOVER_MSG="$CAMERA $LABEL $TYPE $REVERSE_ID"
    #     if [[ "$ZONES" != "[]" ]]; then
    #             PUSHOVER_MSG="$PUSHOVER_MSG in $ZONES"
    #     fi
    #     echo "Message: $PUSHOVER_MSG"
    #     if [[ "$NOTIFICATION_ENABLED" == "true" ]] && [[ $TYPE == "new" ]]; then
    #             curl -s --form-string "token=$PUSHOVER_TOKEN" --form-string "user=$PUSHOVER_USERKEY" --form-string "message=$PUSHOVER_MSG" https://api.pushover.net/1/messages.json
    #     fi
    # fi

    if [[ "$LABEL" =~ ^(person|car|bus|bicycle|motorcycle)$ ]] && [[ "$TYPE" == "end" ]] && [[ "$POS_CHANGES" -gt 0 ]]; then
	{
        date '+%FT%T.%3N'
	    VIDEO_FILE_NAME="event_${REVERSE_ID}_${CAMERA}_${LABEL}.mp4"
	    THUMBNAIL_FILE_NAME="event_${REVERSE_ID}_${CAMERA}_${LABEL}.jpg"
	    PREVIEW_FILE_NAME="event_${REVERSE_ID}_${CAMERA}_${LABEL}.gif"

            MAX_RETRIES=3
            RETRY_COUNT=0
            SUCCESS=false
            WAIT_TIME=10 # Seconds to wait between attempts

            while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
                RETRY_COUNT=$((RETRY_COUNT + 1))
                
                echo "Attempt $RETRY_COUNT: Waiting ${WAIT_TIME}s to download $EVENT_ID..."
                sleep $WAIT_TIME
                
                if curl -sSf --max-time 120 "http://$FRIGATE_HOST:5000/api/events/$EVENT_ID/clip.mp4?padding=5" -o "$CACHE_DIR/$VIDEO_FILE_NAME"; then
                    echo "Success: Saved clip for $EVENT_ID on attempt $RETRY_COUNT: $VIDEO_FILE_NAME."
                    mv "$CACHE_DIR/$VIDEO_FILE_NAME" "$SAVE_DIR/"
                    echo "Downloaded mp4 for $EVENT_ID has successfully moved to $SAVE_DIR at $(date '+%FT%T.%3N')"
                    SUCCESS=true
                    break
                else
                    echo "Attempt $RETRY_COUNT failed for $EVENT_ID at $(date '+%FT%T.%3N')"
                    # Increase wait time for the next attempt (exponential backoff)
                    # WAIT_TIME=$((WAIT_TIME + 10)) 
                fi
            done

            if curl -sSf --max-time 60 "http://$FRIGATE_HOST:5000/api/events/$EVENT_ID/thumbnail.jpg" -o "$SAVE_DIR/$THUMBNAIL_FILE_NAME"; then
                echo "Success: Saved thumbnail for $EVENT_ID: $THUMBNAIL_FILE_NAME."
            else
                echo "Failed to save thumbnail for $EVENT_ID at $(date '+%FT%T.%3N')"
            fi

            if curl -sSf --max-time 60 "http://$FRIGATE_HOST:5000/api/events/$EVENT_ID/preview.gif" -o "$SAVE_DIR/$PREVIEW_FILE_NAME"; then
                echo "Success: Saved preview for $EVENT_ID: $PREVIEW_FILE_NAME."
            else
                echo "Failed to save preview for $EVENT_ID at $(date '+%FT%T.%3N')"
            fi

            if [ "$SUCCESS" == false ]; then
                echo "Final Error: Could not download clip for $EVENT_ID after $MAX_RETRIES attempts: $FILE_NAME at $(date '+%FT%T.%3N')."
            fi
	} &
    fi

    if [[ "$LABEL" =~ ^(person|car|bus|bicycle|motorcycle)$ ]] && [[ -n "$METADATA_FUNC" ]] && [[ "$METADATA_FUNC" != "NOT-SET" ]] && [[ -n "$ZONES" || "$TYPE" == "end" ]]; then
            METADATA_PAYLOAD=$(jq -n \
            --arg event_id "$EVENT_ID" \
            --arg reverse_id "$REVERSE_ID" \
            --arg camera "$CAMERA" \
            --arg label "$LABEL" \
            --arg zones "$ZONES" \
            --arg startTime "$START_TIME" \
            --arg endTime "$END_TIME" \
            '{
                id: $reverse_id,
                eventId: $event_id,
                cameraId: $camera,
                objectType: $label,
                zones: ($zones | fromjson),
                eventStartTime: $startTime,
                eventEndTime: $endTime
            }'
        )   
        echo "Sending metadata to Azure func: $METADATA_PAYLOAD"
        if curl -sSf --max-time 15 --json "$METADATA_PAYLOAD" -H "x-functions-key: $METADATA_KEY" "$METADATA_FUNC"; then
            echo "Metadata successfully posted for $EVENT_ID as $REVERSE_ID" 
        else
            echo "ERROR: could not post metadata for $EVENT_ID as $REVERSE_ID"
        fi
    fi

done

