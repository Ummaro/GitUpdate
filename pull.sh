#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$SCRIPT_DIR/deploy.log"
TIME_STAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(cat "$SCRIPT_DIR/.env" | grep -v '#' | xargs)
fi

# Configure git with credentials if provided
if [ -n "$GIT_USERNAME" ] && [ -n "$GIT_TOKEN" ]; then
    git config --global credential.helper store
    echo "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com" > ~/.git-credentials
fi

# Pull and restart only if there are changes
cd "$PROJECT_ROOT"
git fetch origin

# Detect the default branch name - try multiple methods
DEFAULT_BRANCH=$(git ls-remote --symref origin HEAD | head -1 | grep -oP 'refs/heads/\K.*')
if [ -z "$DEFAULT_BRANCH" ]; then
    # Fallback: try to get the tracking branch of current HEAD
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
fi
if [ -z "$DEFAULT_BRANCH" ]; then
    # Final fallback: use 'main' as default
    DEFAULT_BRANCH="main"
fi

if ! git diff --quiet HEAD origin/$DEFAULT_BRANCH 2>/dev/null; then
    git pull origin $DEFAULT_BRANCH
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