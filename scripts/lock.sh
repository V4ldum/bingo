#!/usr/bin/env bash

LOCK_FILE="/tmp/bingo.lock"
HOME="/root/bingo"
flock -n $LOCK_FILE -c "bash $HOME/bingo/scripts/deploy_if_changed.sh" >> "$HOME/logs/bingo-deploy.log" 2>&1