#!/usr/bin/env python3
from pathlib import Path
import struct

boot = Path("artifacts/freedos/disk.img").read_bytes()[0:512]
print("start", boot[0:3].hex())
for base in range(0x70, 0x130, 16):
    print(f"{base:04x}: {boot[base:base+16].hex()}")
d = struct.unpack("<h", bytes.fromhex("9ce7"))[0]
print("disp E79C signed", d, "bp+d", hex((0x7C00 + d) & 0xFFFF))
print("boot[0x5a:0x5e]", boot[0x5A:0x5E].hex())
for i in range(len(boot) - 3):
    if boot[i : i + 2] == b"\xc7\x46" and boot[i + 2] == 0x5A:
        print(f"mov [bp+5a] imm at {i:#x}", boot[i : i + 7].hex())
    if boot[i : i + 2] == b"\x89\x46" and boot[i + 2] == 0x5A:
        print(f"mov [bp+5a] ax at {i:#x}", boot[i : i + 3].hex())
    if boot[i : i + 2] == b"\x8c\x46" and boot[i + 2] == 0x5A:
        print(f"mov [bp+5a] seg at {i:#x}", boot[i : i + 3].hex())
    if boot[i : i + 2] == b"\x89\x7e" and boot[i + 2] == 0x5A:
        print(f"mov [bp+5a] di at {i:#x}")
    if boot[i : i + 2] == b"\x89\x5e" and boot[i + 2] == 0x5A:
        print(f"mov [bp+5a] bx at {i:#x}")
print("0x1c0:", boot[0x1C0:0x1F0].hex())
print("0xc0:", boot[0xC0:0xF0].hex())
print("0x100:", boot[0x100:0x140].hex())
# Show code around filename search
print("search @0xbf:", boot[0xBF:0xE0].hex())
print("copy @0x1c8:", boot[0x1C8:0x1E0].hex())
