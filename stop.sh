#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIME_STAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="$SCRIPT_DIR/deploy.log"

# Remove the cron job
if crontab -l 2>/dev/null | grep -q "Git-Deployer"; then
    crontab -l 2>/dev/null | grep -v "Git-Deployer" | crontab -
    echo "$TIME_STAMP: Cron job removed successfully" >> "$LOG_FILE"
else
    echo "$TIME_STAMP: Cron job does not exist" >> "$LOG_FILE"
fi