#!/bin/bash


while true; do
  wa_val=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* wa.*/\1/")
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $wa_val" | tee -a iowait.log
  sleep 1
done


