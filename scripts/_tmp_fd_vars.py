#!/usr/bin/env python3
"""Decode FreeDOS boot var layout at BP-relative slots."""
from pathlib import Path
import struct

boot = Path("artifacts/freedos/disk.img").read_bytes()[0:512]
# BPB
print("bytes/sect", struct.unpack_from("<H", boot, 11)[0])
print("sect/clust", boot[13])
print("reserved", struct.unpack_from("<H", boot, 14)[0])
print("fats", boot[16])
print("root ents", struct.unpack_from("<H", boot, 17)[0])
print("sect/fat", struct.unpack_from("<H", boot, 22)[0])
print("sect/track", struct.unpack_from("<H", boot, 24)[0])
print("heads", struct.unpack_from("<H", boot, 26)[0])
print("hidden", struct.unpack_from("<I", boot, 28)[0])

# Walk stores to [bp+disp8] with negative disp
for i in range(len(boot) - 3):
    # 89 76 xx = mov [bp+disp], si
    # 89 7e xx = mov [bp+disp], di
    # 89 46 xx = mov [bp+disp], ax
    # c7 46 xx imm16
    if boot[i] == 0x89 and boot[i + 1] in (0x76, 0x7E, 0x46, 0x56, 0x5E):
        disp = boot[i + 2]
        if disp >= 0x80:
            abs_off = (0x7C00 + disp - 256) & 0xFFFF
            reg = {0x76: "SI", 0x7E: "DI", 0x46: "AX", 0x56: "DX", 0x5E: "BX"}[boot[i + 1]]
            print(f"{i:#x}: mov [bp{disp-256}],{reg} -> {abs_off:#x}")
    if boot[i : i + 2] == b"\xc7\x46":
        disp = boot[i + 2]
        imm = struct.unpack_from("<H", boot, i + 3)[0]
        if disp >= 0x80:
            abs_off = (0x7C00 + disp - 256) & 0xFFFF
            print(f"{i:#x}: mov [bp{disp-256}],{imm:#x} -> {abs_off:#x}")
