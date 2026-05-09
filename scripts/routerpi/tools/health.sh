#!/bin/bash

TEMP=$(vcgencmd measure_temp)
UPTIME=$(uptime -p)

echo "HTTP/1.1 200 OK"
echo "Content-Type: text/plain"
echo ""
echo "Status: OK"
echo "$TEMP"
echo "$UPTIME"
