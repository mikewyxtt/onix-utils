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

usage() {
    echo "Usage: $0 [--sys-dir <path>] <output-file>"
    echo
    echo "Options:"
    echo "  --sys-dir <path>   Path to system directory (default: /onix)"
    echo "  --help             Display this message"
    echo
    exit 1
}

# Path to ONIX system files. Default is /onix
sys_dir=/onix
while [[ $# -gt 0 ]]; do
    case "$1" in
        --sys-dir)
            [[ -n "$2" && ! "$2" =~ ^-- ]] || usage
            sys_dir="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        --*)
            echo "ERROR: Unknown option: $1" >&2
            usage
            ;;
        *)
            output_file="$1"
            shift
            break
            ;;
    esac
done

# If there is anything left after the output filename, there are too many args
if [[ $# -gt 0 ]]; then
    echo "ERROR: Too many arguments: $*" >&2
    usage
fi

# Require output filename
if [[ -z "$output_file" ]]; then
    echo "ERROR: No output filename specified"
    usage
fi

# Check that the extensions root directory exists
if [ ! -d "${sys_dir}" ]; then
    echo "ERROR: '${sys_dir}' does not exist!"
    exit 1
fi

# Files to be included in the initramfs
INITRAMFS_MEMBERS=(
    "${sys_dir}/ss/pm"         # Process Manager

## TODO: Add these once they are implemented
#    "${sys_dir}/ss/mm",        # Memory Manager
#    "${sys_dir}/ss/vfs",       # Virtual File System
#    "${sys_dir}/ss/sched",     # Scheduler
#    "${sys_dir}/dd/acpi",      # ACPI
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
