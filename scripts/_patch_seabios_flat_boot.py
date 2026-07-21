#!/usr/bin/env python3
"""Patch SeaBIOS handle_post to run minimal boot in 32flat (no reloc)."""
from pathlib import Path
import sys

src = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src")
p = src / "src/post.c"
t = p.read_text()

old = """void VISIBLE32FLAT
handle_post(void)
{
    if (!CONFIG_QEMU && !CONFIG_COREBOOT)
        return;

    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();

    // Check if we are running under Xen.
    xen_preinit();

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();

    // Now that memory is read/writable - start post process.
    dopost();
}"""

# Use putc breadcrumbs to avoid newline escaping issues in patches
new = """void VISIBLE32FLAT
handle_post(void)
{
    if (!CONFIG_QEMU && !CONFIG_COREBOOT)
        return;

    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();

    /* openx86: flat minimal boot (skip reloc/dopost/prepareboot) */
    PlatformRunningOn |= PF_QEMU;
    RamSize = 640 * 1024;
    HaveRunPost = 1;
    serial_debug_putc('M');
    ivt_init();
    serial_debug_putc('N');
    bda_init();
    serial_debug_putc('O');
    dma_setup();
    pic_setup();
    timer_setup();
    clock_setup();
    serial_debug_putc('P');
    block_setup();
    serial_debug_putc('T');
    startBoot();
    serial_debug_putc('!');
    irq_disable();
    for (;;)
        hlt();
}"""

if "openx86: flat minimal boot" in t:
    print("already: flat minimal boot")
elif old not in t:
    raise SystemExit("missing handle_post pattern (need early cli patch first)")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched: flat minimal boot")
