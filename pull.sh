#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="./deploy.log"
TIME_STAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Pull and restart only if there are changes
cd "$PROJECT_ROOT"
git fetch origin
if ! git diff --quiet HEAD origin/main; then
    git pull origin main
    DEPLOY_OUTPUT=$(bash deploy.sh 2>&1)
    DEPLOY_STATUS=$?
    if [ $DEPLOY_STATUS -eq 0 ]; then
        echo "$TIME_STAMP: Changes pulled and deployment script executed successfully" >> "$LOG_FILE"
        echo "$TIME_STAMP: Deploy output:" >> "$LOG_FILE"
        echo "$DEPLOY_OUTPUT" >> "$LOG_FILE"
    else
        echo "$TIME_STAMP: Changes pulled but deployment script failed with status $DEPLOY_STATUS" >> "$LOG_FILE"
        echo "$TIME_STAMP: Deploy output:" >> "$LOG_FILE"
        echo "$DEPLOY_OUTPUT" >> "$LOG_FILE"
    fi
else
    echo "$TIME_STAMP: No changes detected" >> "$LOG_FILE"
fi