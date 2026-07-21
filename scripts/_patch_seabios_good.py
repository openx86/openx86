#!/usr/bin/env python3
"""Apply known-good openx86 SeaBIOS patches (call-in-place reloc)."""
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
        raise SystemExit(f"missing pattern for {name}")
    p.write_text(t.replace(old, new, 1))
    print("patched:", name)


patch(
    "src/hw/serialio.c",
    """    if (oldparam != newparam || oldier != newier)
        dprintf(1, \"Changing serial settings was %x/%x now %x/%x\\n\"
                , oldparam, oldier, newparam, newier);""",
    """    (void)oldparam;
    (void)oldier;
    (void)newparam;
    (void)newier;
    /* openx86: skip early %x */""",
    "openx86: skip early %x",
)

patch(
    "src/hw/serialio.c",
    """void
serial_debug_flush(void)
{
    if (!CONFIG_DEBUG_SERIAL && (!CONFIG_DEBUG_SERIAL_MMIO || MODESEGMENT))
        return;
    int timeout = DEBUG_TIMEOUT;
    while ((serial_debug_read(SEROFF_LSR) & 0x60) != 0x60)
        if (!timeout--)
            // Ran out of time.
            return;
}""",
    """void
serial_debug_flush(void)
{
    /* openx86: flush nop */
    return;
}""",
    "openx86: flush nop",
)

patch(
    "src/output.c",
    """void
debug_banner(void)
{
    dprintf(1, \"SeaBIOS (version %s)\\n\", VERSION);
    dprintf(1, \"BUILD: %s\\n\", BUILDINFO);
}""",
    """void
debug_banner(void)
{
    /* openx86: plain banner only (no %s) */
    dprintf(1, \"SeaBIOS\\n\");
}""",
    "openx86: plain banner only",
)

patch(
    "src/fw/shadow.c",
    """void
make_bios_writable(void)
{
    if (!CONFIG_QEMU || runningOnXen())
        return;

    dprintf(3, \"enabling shadow ram\\n\");""",
    """void
make_bios_writable(void)
{
    /* openx86: skip PCI PAM */
    code_mutable_preinit();
    return;
    if (!CONFIG_QEMU || runningOnXen())
        return;

    dprintf(3, \"enabling shadow ram\\n\");""",
    "openx86: skip PCI PAM",
)

patch(
    "src/fw/paravirt.c",
    """void
qemu_preinit(void)
{
    qemu_detect();
    kvm_detect();

    if (!CONFIG_QEMU)
        return;
""",
    """void
qemu_preinit(void)
{
    /* openx86: qemu_preinit stub */
    PlatformRunningOn |= PF_QEMU;
    RamSize = 640 * 1024;
    return;
    qemu_detect();
    kvm_detect();

    if (!CONFIG_QEMU)
        return;
""",
    "openx86: qemu_preinit stub",
)

patch(
    "src/malloc.c",
    """void
malloc_preinit(void)
{
    ASSERT32FLAT();
    dprintf(3, \"malloc preinit\\n\");
""",
    """void
malloc_preinit(void)
{
    /* openx86: malloc_preinit empty */
    return;
    ASSERT32FLAT();
    dprintf(3, \"malloc preinit\\n\");
""",
    "openx86: malloc_preinit empty",
)

patch(
    "src/post.c",
    """void __noreturn
reloc_preinit(void *f, void *arg)
{
    void (*func)(void *) __noreturn = f;
    if (!CONFIG_RELOCATE_INIT)
        func(arg);

    // Allocate space for init code.
    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);""",
    """void __noreturn
reloc_preinit(void *f, void *arg)
{
    /* openx86: reloc call-in-place */
    void (*func)(void *) __noreturn = f;
    func(arg);
    return;
    if (!CONFIG_RELOCATE_INIT)
        func(arg);

    // Allocate space for init code.
    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);""",
    "openx86: reloc call-in-place",
)

patch(
    "src/post.c",
    """// Main setup code.
static void
maininit(void)
{
    // Initialize internal interfaces.
    interface_init();
""",
    """// Main setup code.
static void
maininit(void)
{
    /* openx86: minimal maininit */
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
    serial_debug_putc('Q');
    prepareboot();
    serial_debug_putc('T');
    startBoot();
    serial_debug_putc('!');
    irq_disable();
    for (;;)
        hlt();
    // Initialize internal interfaces.
    interface_init();
""",
    "openx86: minimal maininit",
)

patch(
    "src/post.c",
    """    serial_debug_preinit();
    debug_banner();
""",
    """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();
""",
    "openx86: early cli",
)

print("all patches applied")
