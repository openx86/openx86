from pathlib import Path
import re

# Point IVT INT13 at F000:9000 (stub embedded in ROM)
for path in [
    "artifacts/seabios/src/src/post.c",
    "scripts/_patch_seabios_good.py",
]:
    p = Path(path)
    t = p.read_text()
    t2 = t.replace("u32 v13 = 0x00009000,", "u32 v13 = 0xF0009000,")
    if t2 == t:
        raise SystemExit(f"v13 not found in {path}")
    p.write_text(t2)
    print("ivt", path)
