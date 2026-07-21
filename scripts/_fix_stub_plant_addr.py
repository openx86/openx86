from pathlib import Path

old = 'asm volatile("movl %0, (%1)" : : "r"(w), "r"(0x9000 + i * 4) : "memory");'
new = (
    'u32 *d = (u32 *)(0x9000 + (i << 2));\n'
    '                asm volatile("movl %0, (%1)" : : "r"(w), "r"(d) : "memory");'
)

for path in [
    "artifacts/seabios/src/src/post.c",
    "scripts/_patch_seabios_good.py",
]:
    p = Path(path)
    t = p.read_text()
    if old not in t:
        raise SystemExit(f"not found in {path}")
    p.write_text(t.replace(old, new, 1))
    print("fixed", path)
