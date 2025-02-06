#!/usr/bin/env bash

HOME="/root/bingo"

cd "$HOME/bingo"
git pull

BUILD_VERSION=$(git rev-parse HEAD)
echo "$(date --utc +%FT%TZ): Releasing new bingo version : $BUILD_VERSION"

echo "$(date --utc +%FT%TZ): Running build..."
docker build -t bingo .

echo "$(date --utc +%FT%TZ): Running container..."
cd /root
OLD_CONTAINER=$(docker ps -aqf "name=bingo")

docker container rm -f $OLD_CONTAINER > /dev/null
docker compose up -d --no-deps --no-recreate bingo