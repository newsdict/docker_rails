#!/bin/sh
echo `grep ARG Dockerfile` | sed 's/ARG \(\w\+\)_version\="\([0-9\.v]\+\)"/\1_\2/g' |sed 's/ /_/g'