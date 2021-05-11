#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

git fetch --all || true
git fetch --tags || true
git remote | xargs -I {} git rebase "{}/$(git branch --show-current)" || true
