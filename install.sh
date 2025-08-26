#!/bin/bash

# This script installs the utilities. Default is to install the utilities to /usr/sbin

if [ -z "$1" ]; then
    DESTDIR="/usr/sbin"
else
    DESTDIR="$1"
fi
