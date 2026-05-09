#!/bin/bash

TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
UPTIME=$(uptime -p)

echo "HTTP/1.1 200 OK"
echo "Content-Type: application/json"
echo ""
echo "{\"status\": \"OK\", \"temperature\": \"$TEMP\", \"uptime\": \"$UPTIME\"}"
