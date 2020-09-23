#!/bin/bash -l
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd ".."

find "." -name "*.ebuild" -exec ebuild "{}" manifest \;
