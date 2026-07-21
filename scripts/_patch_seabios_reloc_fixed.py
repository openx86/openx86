#!/usr/bin/env python3
"""Replace entire reloc_preinit with memcpy+updateRelocs fixed reloc."""
from pathlib import Path
import sys

src = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src")
p = src / "src/post.c"
t = p.read_text()

start = t.find("void __noreturn\nreloc_preinit(void *f, void *arg)\n{")
if start < 0:
    raise SystemExit("reloc_preinit start not found")
end_marker = "\n// Runs after all code is present"
end = t.find(end_marker, start)
if end < 0:
    raise SystemExit("end marker not found")
body_end = t.rfind("\n}", start, end) + 2

mode = sys.argv[2] if len(sys.argv) > 2 else "full"

if mode == "tiny":
    new_fn = (
        "void __noreturn\n"
        "reloc_preinit(void *f, void *arg)\n"
        "{\n"
        "    /* openx86: reloc tiny */\n"
        "    void (*func)(void *) __noreturn = f;\n"
        "    func(arg);\n"
        "    for (;;)\n"
        "        hlt();\n"
        "}"
    )
elif mode == "memcpy":
    new_fn = (
        "void __noreturn\n"
        "reloc_preinit(void *f, void *arg)\n"
        "{\n"
        "    /* openx86: reloc memcpy-only */\n"
        "    void (*func)(void *) __noreturn = f;\n"
        "    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);\n"
        "    void *codesrc = VSYMBOL(code32init_start);\n"
        "    void *codedest = (void*)0x00030000;\n"
        "    s32 delta = (s32)codedest - (s32)codesrc;\n"
        "    memcpy(codedest, codesrc, initsize);\n"
        "    if (f >= codesrc && f < VSYMBOL(code32init_end))\n"
        "        func = (void*)((u8*)f + delta);\n"
        "    serial_debug_putc('R');\n"
        "    barrier();\n"
        "    func(arg);\n"
        "    for (;;)\n"
        "        hlt();\n"
        "}"
    )
else:
    new_fn = (
        "void __noreturn\n"
        "reloc_preinit(void *f, void *arg)\n"
        "{\n"
        "    /* openx86: fixed-address reloc */\n"
        "    void (*func)(void *) __noreturn = f;\n"
        "    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);\n"
        "    u32 codealign = SYMBOL(_reloc_min_align);\n"
        "    void *codesrc = VSYMBOL(code32init_start);\n"
        "    u32 dest = 0x00030000;\n"
        "    dest = (dest + codealign - 1) & ~(codealign - 1);\n"
        "    void *codedest = (void*)dest;\n"
        "    s32 delta = (s32)codedest - (s32)codesrc;\n"
        "    memcpy(codedest, codesrc, initsize);\n"
        "    updateRelocs(codedest, VSYMBOL(_reloc_abs_start), VSYMBOL(_reloc_abs_end), delta);\n"
        "    updateRelocs(codedest, VSYMBOL(_reloc_rel_start), VSYMBOL(_reloc_rel_end), -delta);\n"
        "    updateRelocs(VSYMBOL(code32flat_start), VSYMBOL(_reloc_init_start),\n"
        "                 VSYMBOL(_reloc_init_end), delta);\n"
        "    if (f >= codesrc && f < VSYMBOL(code32init_end))\n"
        "        func = (void*)((u8*)f + delta);\n"
        "    serial_debug_putc('R');\n"
        "    barrier();\n"
        "    func(arg);\n"
        "    for (;;)\n"
        "        hlt();\n"
        "}"
    )

p.write_text(t[:start] + new_fn + t[body_end:])
print("ok:", mode, "reloc, bytes", len(new_fn))
