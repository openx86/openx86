#!/usr/bin/env python3
"""Extra SeaBIOS bring-up patches: skip RTC, post-banner crumbs."""
from pathlib import Path
import sys

src = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src")


def patch(path, old, new, name):
    p = src / path
    t = p.read_text()
    if name in t:
        print("already:", name)
        return
    if old not in t:
        raise SystemExit(f"missing {name}")
    p.write_text(t.replace(old, new, 1))
    print("patched:", name)


patch(
    "src/post.c",
    """void
code_mutable_preinit(void)
{
    if (HaveRunPost)
        // Already run
        return;
    // Setup reset-vector entry point (controls legacy reboots).
    rtc_write(CMOS_RESET_CODE, 0);
    barrier();
    HaveRunPost = 1;
    barrier();
}""",
    """void
code_mutable_preinit(void)
{
    /* openx86: skip RTC in code_mutable_preinit */
    if (HaveRunPost)
        return;
    HaveRunPost = 1;
    barrier();
}""",
    "openx86: skip RTC in code_mutable_preinit",
)

patch(
    "src/post.c",
    """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();

    // Check if we are running under Xen.
    xen_preinit();

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();

    // Now that memory is read/writable - start post process.
    dopost();
}""",
    """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();
    serial_debug_putc('B');

    // Check if we are running under Xen.
    xen_preinit();
    serial_debug_putc('C');

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();
    serial_debug_putc('D');

    // Now that memory is read/writable - start post process.
    dopost();
}""",
    "openx86: post-banner crumbs",
)

# malloc_preinit: add ZoneTmpLow so later allocs can work
patch(
    "src/malloc.c",
    """void
malloc_preinit(void)
{
    /* openx86: malloc_preinit empty */
    return;
    ASSERT32FLAT();
    dprintf(3, \"malloc preinit\\n\");
""",
    """void
malloc_preinit(void)
{
    /* openx86: malloc_preinit minimal zones */
    ASSERT32FLAT();
    alloc_add(&ZoneTmpLow, 0x00010000, 0x00080000);
    /* Stay within 1MiB behavioral SDRAM window used by the SoC TB */
    alloc_add(&ZoneTmpHigh, 0x00080000, 0x000A0000);
    return;
    dprintf(3, \"malloc preinit\\n\");
""",
    "openx86: malloc_preinit minimal zones",
)
