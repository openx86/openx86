# Embed INT13 stub into bios.bin at PA 0xF9000 (F000:9000) and
# document the IVT target. Also regenerate plant to use F000:9000.
from pathlib import Path

stub = Path("artifacts/seabios/int13_stub.bin").read_bytes()
bios_path = Path("artifacts/seabios/bios.bin")
bios = bytearray(bios_path.read_bytes())
# 128KiB ROM at 0xE0000..0xFFFFF → file offset = PA - 0xE0000
pa = 0xF9000
off = pa - 0xE0000
if off + len(stub) > len(bios):
    raise SystemExit("stub does not fit in ROM")
bios[off : off + len(stub)] = stub
bios_path.write_bytes(bios)
Path("artifacts/seabios/dos_bios.bin").write_bytes(bios)
print(f"embedded stub at PA {pa:#x} file off {off:#x} size {len(stub)}")
print("first4", stub[:4].hex())
