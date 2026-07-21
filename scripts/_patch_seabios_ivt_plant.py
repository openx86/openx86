#!/usr/bin/env python3
from pathlib import Path
import sys

p = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src") / "src/post.c"
t = p.read_text()
old = """    irq_disable(); /* openx86: early cli */
    asm volatile("movl $0x0008ff00, %%esp" ::: "esp");
    serial_debug_preinit();
    debug_banner();

    /* openx86: call maininit directly from flat handle_post */
    serial_debug_putc('H');
    maininit();
"""
new = """    irq_disable(); /* openx86: early cli */
    asm volatile("movl $0x0008ff00, %%esp" ::: "esp");
    /* openx86: mask PICs and plant iret stubs in IVT before any IO */
    outb(0xff, PORT_PIC1_DATA);
    outb(0xff, PORT_PIC2_DATA);
    *(u8*)0x800 = 0xcf;
    {
        int i;
        for (i = 0; i < 256; i++) {
            *(u16*)(i * 4) = 0x0800;
            *(u16*)(i * 4 + 2) = 0x0000;
        }
    }
    serial_debug_preinit();
    debug_banner();

    /* openx86: call maininit directly from flat handle_post */
    serial_debug_putc('H');
    maininit();
"""
if "plant iret stubs" in t:
    print("already: ivt plant")
elif old not in t:
    raise SystemExit("pattern missing for ivt plant")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched: ivt plant")
