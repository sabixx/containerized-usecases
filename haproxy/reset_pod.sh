#!/bin/sh

# Find the ttyd process ID (PID)
PID=$(pgrep -f "ttyd --writable -p 7681 /bin/sh -l")

# Check if the PID exists
if [ -n "$PID" ]; then
  echo "Terminating ttyd process with PID $PID..."
  kill -TERM "$PID"
  echo "Process terminated. Pod will restart."
else
  echo "ttyd process not found."
fi
