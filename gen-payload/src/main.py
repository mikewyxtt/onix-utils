#!/usr/bin/env python3

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

import sys
import os
import struct
import subprocess

def usage():
    print(f"""Usage: {sys.argv[0]} <root-task> <initramfs> <payload>

  <root-task>       Path to the root task binary
  <initramfs>       Path to the initramfs
  <payload>         Where to write the payload
""", file=sys.stderr)

def main():
    if len(sys.argv) < 4 or len(sys.argv) > 4:
        usage()
        sys.exit(1)

    root_elf = sys.argv[1]
    initramfs = sys.argv[2]
    output_elf = sys.argv[3]

    if not os.path.isfile(root_elf):
        sys.stderr.write(f"Error: ELF not found: {root_elf}\n")
        sys.exit(1)

    if not os.path.isfile(initramfs):
        sys.stderr.write(f"Error: initramfs archive not found: {initramfs}\n")
        sys.exit(1)

    # Read initramfs data
    with open(initramfs, "rb") as f:
        initramfs = f.read()
   

    # Build binary blob
    magic = b"RAMFS"
    length_field = struct.pack("<i", len(initramfs))  # signed little-endian 32-bit
    blob = magic + length_field + initramfs

    # Write blob to temporary file
    blob_path = "initramfs_blob.bin"
    with open(blob_path, "wb") as f:
        f.write(blob)

    # Inject blob into .initramfs section using objcopy
    try:
        subprocess.run([
            "objcopy",
            "--update-section",
            f".initramfs={blob_path}",
            root_elf,
            output_elf
        ], check=True)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"Error: objcopy failed with exit code {e.returncode}")

    print(f"✅ Patched ELF written to: {output_elf}")

if __name__ == "__main__":
    main()
