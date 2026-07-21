#!/usr/bin/env python3
"""Final SeaBIOS bring-up: flat dopost -> maininit, no reloc call."""
from pathlib import Path
import sys

# Reuse bringup base then adjust dopost/maininit linkage
import importlib.util

root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))

src = Path(sys.argv[1] if len(sys.argv) > 1 else root / "artifacts/seabios/src")

# Run bringup first by exec
bringup = Path(__file__).resolve().parent / "_patch_seabios_bringup.py"
spec = importlib.util.spec_from_file_location("bringup", bringup)
mod = importlib.util.module_from_spec(spec)
# bringup expects sys.argv[1]
sys.argv = [str(bringup), str(src)]
spec.loader.exec_module(mod)

p = src / "src/post.c"
t = p.read_text()

# Change dopost to FLAT and call maininit directly
old = """void VISIBLE32INIT
dopost(void)
{
    /* openx86: dopost entry crumb */
    serial_debug_putc('D');
    code_mutable_preinit();

    // Detect ram and setup internal malloc.
    qemu_preinit();
    coreboot_preinit();
    malloc_preinit();

    // Relocate initialization code and call maininit().
    reloc_preinit(maininit, NULL);
}"""

new = """void VISIBLE32FLAT
dopost(void)
{
    /* openx86: flat dopost calls maininit in-place */
    serial_debug_putc('D');
    code_mutable_preinit();
    qemu_preinit();
    coreboot_preinit();
    malloc_preinit();
    maininit();
    for (;;)
        hlt();
    reloc_preinit(maininit, NULL);
}"""

if "openx86: flat dopost calls maininit" in t:
    print("already: flat dopost")
elif old not in t:
    raise SystemExit("dopost pattern missing")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched: flat dopost -> maininit")
