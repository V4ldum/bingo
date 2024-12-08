#!/usr/bin/env bash


HOME="/home/bingo"
cd "$HOME/bingo"

#echo "$(date --utc +%FT%TZ): Fetching remote repository..."
git fetch
DIFF=$(git diff main origin/main --name-only > /dev/null; echo $?)

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
        #echo "$(date --utc +%FT%TZ): No changes detected"
        :
elif [ $LOCAL = $BASE ]; then
        BUILD_VERSION=$(git rev-parse HEAD)

        if [ $DIFF = 0 ]; then
                echo "$(date --utc +%FT%TZ): Changes detected, deploying new version: $BUILD_VERSION"
                bash scripts/deploy.sh
        fi
elif [ $REMOTE = $BASE ]; then
        BUILD_VERSION=$(git rev-parse HEAD)

        echo "$(date --utc +%FT%TZ): Local changes detected, stashing"
        git stash

        if [ $DIFF = 0 ]; then
                echo "$(date -utc +%FT%TZ): Changes detected, deploying new version: $BUILD_VERSION"
                bash scripts/deploy.sh
        fi
else
        echo "$(date --utc +%FT%TZ): Git is diverged, this is unexpected."
fi