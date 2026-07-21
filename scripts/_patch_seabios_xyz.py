#!/usr/bin/env python3
from pathlib import Path
import sys

p = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src") / "src/post.c"
t = p.read_text()
old = """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();

    // Check if we are running under Xen.
    xen_preinit();

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();

    // Now that memory is read/writable - start post process.
    dopost();
}"""
new = """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();
    serial_debug_putc('X');

    // Check if we are running under Xen.
    xen_preinit();
    serial_debug_putc('Y');

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();
    serial_debug_putc('Z');

    // Now that memory is read/writable - start post process.
    dopost();
}"""
if "serial_debug_putc('X')" in t:
    print("already XYZ")
elif old not in t:
    idx = t.find("openx86: early cli")
    print("NO MATCH near", repr(t[idx:idx+350]))
    sys.exit(1)
else:
    p.write_text(t.replace(old, new, 1))
    print("patched XYZ crumbs")
