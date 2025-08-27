#!/bin/bash

# This script installs the utilities. Default is to install the utilities to /usr/sbin
set -e

export DESTDIR="${1:-/usr/sbin}"

TGTS=$(find . -name install.sh -exec realpath {} \;)

for tgt in $TGTS; do
    (cd $(dirname $tgt) && $tgt)
done
