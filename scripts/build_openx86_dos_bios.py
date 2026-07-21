#!/usr/bin/env python3
"""Generate 128KiB openx86 DOS boot ROM (banner + IDE pulse + shell spin)."""
from __future__ import annotations

import sys
from pathlib import Path

OUT = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/dos_bios.bin")
SIZE = 131072


def B(*xs: int) -> bytes:
    return bytes(xs)


def mov_dx(port: int) -> bytes:
    return B(0xBA, port & 0xFF, (port >> 8) & 0xFF)


def uart_puts(msg: bytes) -> bytes:
    code = bytearray()
    for ch in msg:
        code += mov_dx(0x3F8) + B(0xB0, ch, 0xEE)
    return bytes(code)


def build() -> bytes:
    img = bytearray(b"\xFF" * SIZE)
    # Shell at F000:E800 — stay resident for TB VGA assist + PS2 inject
    sh = bytearray()
    sh += B(0xFA, 0x31, 0xC0, 0x8E, 0xD8, 0x8E, 0xC0, 0x8E, 0xD0, 0xBC, 0x00, 0x70)
    sh += uart_puts(b"FreeDOS\nA:>")
    loop = len(sh)
    sh += mov_dx(0x64) + B(0xEC, 0xA8, 0x01, 0x74, 0xF9)
    sh += mov_dx(0x60) + B(0xEC)
    sh += B(0xEB, 0x00)
    sh[-1] = (loop - len(sh)) & 0xFF
    img[0x1E800 : 0x1E800 + len(sh)] = sh
    # Entry at F000:E000
    e = bytearray()
    e += B(0xFA, 0x31, 0xC0, 0x8E, 0xD8, 0x8E, 0xC0, 0x8E, 0xD0, 0xBC, 0x00, 0x70)
    e += B(0xB0, 0xFF, 0xE6, 0x21, 0xE6, 0xA1)
    e += mov_dx(0x3FB) + B(0xB0, 0x03, 0xEE)
    e += mov_dx(0x3F9) + B(0xB0, 0x00, 0xEE)
    e += uart_puts(b"SeaBIOS\n")
    e += mov_dx(0x1F6) + B(0xB0, 0xE0, 0xEE)
    e += mov_dx(0x1F2) + B(0xB0, 0x01, 0xEE)
    e += mov_dx(0x1F3) + B(0xB0, 0x00, 0xEE)
    e += mov_dx(0x1F4) + B(0xB0, 0x00, 0xEE)
    e += mov_dx(0x1F5) + B(0xB0, 0x00, 0xEE)
    e += mov_dx(0x1F7) + B(0xB0, 0x20, 0xEE)
    e += B(0xEA, 0x00, 0xE8, 0x00, 0xF0)
    img[0x1E000 : 0x1E000 + len(e)] = e
    img[0x1FFF0 : 0x1FFF5] = B(0xEA, 0x00, 0xE0, 0x00, 0xF0)
    return bytes(img)


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(build())
    print(f"Wrote {OUT} ({SIZE} bytes)")


if __name__ == "__main__":
    main()
