#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="./deploy.log"
TIME_STAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Pull and restart only if there are changes
CRON_JOB="*/5 * * * * "$SCRIPT_DIR"/pull.sh"

# Check if cron job already exists
if ! crontab -l 2>/dev/null | grep -q "Git-Deployer"; then
    echo "$CRON_JOB" | crontab -
    echo "$TIME_STAMP: Cron job added successfully" >> "$LOG_FILE"
else
    echo "$TIME_STAMP: Cron job already exists" >> "$LOG_FILE"
fi