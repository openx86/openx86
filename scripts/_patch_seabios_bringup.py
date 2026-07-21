#!/usr/bin/env python3
"""Apply working openx86 SeaBIOS bring-up set for FreeDOS boot."""
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


# --- from _patch_seabios_good.py (inline) ---
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
    "src/hw/rtc.c",
    """void
rtc_write(u8 index, u8 val)
{
    index |= NMI_DISABLE_BIT;
    outb(index, PORT_CMOS_INDEX);
    outb(val, PORT_CMOS_DATA);
}""",
    """void
rtc_write(u8 index, u8 val)
{
    /* openx86: rtc_write: disable NMI only (skip data) */
    outb(index | NMI_DISABLE_BIT, PORT_CMOS_INDEX);
    (void)val;
}""",
    "openx86: rtc_write nop",
)

# Replace entire reloc_preinit
p = src / "src/post.c"
t = p.read_text()
start = t.find("void __noreturn\nreloc_preinit(void *f, void *arg)\n{")
if start < 0:
    raise SystemExit("reloc_preinit not found")
end_marker = "\n// Runs after all code is present"
end = t.find(end_marker, start)
body_end = t.rfind("\n}", start, end) + 2
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
t = t[:start] + new_fn + t[body_end:]
p.write_text(t)
print("patched: openx86: fixed-address reloc")

# Re-read and patch maininit / early cli / dopost crumb
t = p.read_text()

patch_main_old = """// Main setup code.
static void
maininit(void)
{
    // Initialize internal interfaces.
    interface_init();
"""
patch_main_new = """// Main setup code.
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
"""
if "openx86: minimal maininit" not in t:
    if patch_main_old not in t:
        raise SystemExit("missing maininit")
    t = t.replace(patch_main_old, patch_main_new, 1)
    print("patched: openx86: minimal maininit")
else:
    print("already: openx86: minimal maininit")

cli_old = """    serial_debug_preinit();
    debug_banner();
"""
cli_new = """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();
"""
if "openx86: early cli" not in t:
    if cli_old not in t:
        raise SystemExit("missing early cli site")
    t = t.replace(cli_old, cli_new, 1)
    print("patched: openx86: early cli")
else:
    print("already: openx86: early cli")

dopost_old = """void VISIBLE32INIT
dopost(void)
{
    code_mutable_preinit();
"""
dopost_new = """void VISIBLE32INIT
dopost(void)
{
    /* openx86: dopost entry crumb */
    serial_debug_putc('D');
    code_mutable_preinit();
"""
if "openx86: dopost entry crumb" not in t:
    if dopost_old not in t:
        raise SystemExit("missing dopost")
    t = t.replace(dopost_old, dopost_new, 1)
    print("patched: openx86: dopost entry crumb")
else:
    print("already: openx86: dopost entry crumb")

p.write_text(t)
print("all bring-up patches applied")
