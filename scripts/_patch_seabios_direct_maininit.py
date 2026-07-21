#!/usr/bin/env python3
from pathlib import Path
import sys
import importlib.util

root = Path(__file__).resolve().parent
src = Path(sys.argv[1] if len(sys.argv) > 1 else root.parent / "artifacts/seabios/src")

bringup = root / "_patch_seabios_bringup.py"
spec = importlib.util.spec_from_file_location("bringup", bringup)
mod = importlib.util.module_from_spec(spec)
sys.argv = [str(bringup), str(src)]
spec.loader.exec_module(mod)

# layoutrom
layout = root / "_patch_seabios_layoutrom.py"
spec2 = importlib.util.spec_from_file_location("layout", layout)
mod2 = importlib.util.module_from_spec(spec2)
sys.argv = [str(layout), str(src)]
spec2.loader.exec_module(mod2)

p = src / "src/post.c"
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
    asm volatile("movl $0x0008ff00, %%esp" ::: "esp");
    serial_debug_preinit();
    debug_banner();

    /* openx86: call maininit directly from flat handle_post */
    serial_debug_putc('H');
    maininit();
    for (;;)
        hlt();

    // Keep post/reloc linkage for ROM layout stability.
    xen_preinit();
    make_bios_writable();
    dopost();
}"""

if "openx86: call maininit directly" in t:
    print("already: direct maininit")
elif old not in t:
    raise SystemExit("handle_post pattern missing")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched: direct maininit from handle_post")
