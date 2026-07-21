#!/usr/bin/env python3
"""Replace call-in-place reloc with memcpy-only fixed reloc (no updateRelocs)."""
from pathlib import Path
import sys

src = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src")
p = src / "src/post.c"
t = p.read_text()

old = """    /* openx86: reloc call-in-place */
    void (*func)(void *) __noreturn = f;
    func(arg);
    return;
"""

new = """    /* openx86: reloc memcpy-only */
    void (*func)(void *) __noreturn = f;
    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);
    void *codesrc = VSYMBOL(code32init_start);
    void *codedest = (void*)0x00030000;
    s32 delta = (s32)codedest - (s32)codesrc;
    memcpy(codedest, codesrc, initsize);
    if (f >= codesrc && f < VSYMBOL(code32init_end))
        func = (void*)((u8*)f + delta);
    barrier();
    func(arg);
    return;
"""

if "openx86: reloc memcpy-only" in t:
    print("already: memcpy-only reloc")
elif old not in t:
    raise SystemExit("missing call-in-place block")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched: memcpy-only reloc")
