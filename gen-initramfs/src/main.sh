#!/bin/bash

#
#  Copyright (C) 2025  Mike Wyatt <mikewyxtt@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -e

# Path to ONIX system files
ONIX_SYS=${$1:-"/onix"}

if [ ! -d "${ONIX_SYS}" ]; then
    echo "ERROR: Extensions root directory '${ONIX_SYS}' does not exist!"
    exit 1
fi

# Files to be included in the initramfs
INITRAMFS_MEMBERS=(
    "${ONIX_SYS}/ss/pm"         # Process Manager

## TODO: Add these once they are implemented
#    "${ONIX_SYS}/ss/mm",        # Memory Manager
#    "${ONIX_SYS}/ss/vfs",       # Virtual File System
#    "${ONIX_SYS}/ss/sched",     # Scheduler
#    "${ONIX_SYS}/dd/acpi",      # ACPI
#   
)

INITRAMFS_TMP_DIR=$(mktemp -d /tmp/initramfs.XXXXXX)
OUTPUT_FILE=$1

for m in ${INITRAMFS_MEMBERS[@]}; do
    cp -v ${m} ${INITRAMFS_TMP_DIR}
done

# Create the initramfs
(
    cd ${INITRAMFS_TMP_DIR}
    find . | cpio -o -H newc
) > ${OUTPUT_FILE}

rm -rf ${INITRAMFS_TMP_DIR}
