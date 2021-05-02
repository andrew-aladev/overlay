#!/usr/bin/env bash
set -e

env-update
source "/etc/profile"

DIR="/mnt/data"

if [ ! -d "$DIR" ]; then
  mkdir -p "$DIR"

  git clone "https://github.com/andrew-aladev/overlay.git" \
    --single-branch \
    --branch "master" \
    --depth 1 \
    "$DIR"
fi

cd "$DIR"

eix-update
./scripts/ci_test.sh
