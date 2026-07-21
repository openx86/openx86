#!/usr/bin/env python3
"""Restore openx86 post.c patches after accidental wipe."""
from pathlib import Path

p = Path("artifacts/seabios/src/src/post.c")
t = p.read_text()

t = t.replace(
    """    e820_add((u32)ebda, BUILD_LOWRAM_END-(u32)ebda, E820_RESERVED);

    // Init extra stack""",
    """    /* openx86: skip e820_add — can hang when 16bit code size grows */

    // Init extra stack""",
    1,
)

old_prep = """void
prepareboot(void)
{
    // Change TPM phys. presence state befor leaving BIOS
    tpm_prepboot();

    // Run BCVs
    bcv_prepboot();

    // Finalize data structures before boot
    cdrom_prepboot();
    pmm_prepboot();
    malloc_prepboot();
    e820_prepboot();

    HaveRunPost = 2;

    // Setup bios checksum.
    BiosChecksum -= checksum((u8*)BUILD_BIOS_ADDR, BUILD_BIOS_SIZE);
}"""
new_prep = """void
prepareboot(void)
{
    /* openx86: minimal prepareboot */
    HaveRunPost = 2;
}"""
assert old_prep in t, "prepareboot missing"
t = t.replace(old_prep, new_prep, 1)

old_sb = """void VISIBLE32FLAT
startBoot(void)
{
    // Clear low-memory allocations (required by PMM spec).
    memset((void*)BUILD_STACK_ADDR, 0, BUILD_EBDA_MINIMUM - BUILD_STACK_ADDR);

    dprintf(3, \"Jump to int19\\n\");
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    call16_int(0x19, &br);
}"""
new_sb = """void VISIBLE32FLAT
startBoot(void)
{
    /* openx86: do not wipe BUILD_STACK_ADDR..EBDA (clears live stack) */
    /* Direct ATA READ LBA0 → 0x7C00, then far jump (skip fragile call16_int).
     * Use dword stores: halfword/byte BE path still drops odd-lane writes. */
    u32 *dst = (u32 *)0x7C00;
    int i;
    u8 st;
    serial_debug_putc('B');
    serial_debug_putc('o');
    { volatile int d; for (d = 0; d < 64; d++) ; }
    serial_debug_putc('o');
    serial_debug_putc('t');
    serial_debug_putc('i');
    serial_debug_putc('n');
    serial_debug_putc('g');
    serial_debug_putc('\\n');

    outb(0xa0 | 0x40, 0x1f6); /* LBA mode, drive 0 */
    outb(0x01, 0x1f2);        /* 1 sector */
    outb(0x00, 0x1f3);
    outb(0x00, 0x1f4);
    outb(0x00, 0x1f5);
    outb(0x20, 0x1f7);        /* READ SECTORS */
    for (i = 0; i < 256; i++) {
        st = inb(0x1f7);
        if (!(st & 0x80) && (st & 0x08))
            break;
    }
    if (i >= 256 || !(st & 0x08)) {
        serial_debug_putc('r');
        return;
    }
    for (i = 0; i < 128; i++) {
        u32 lo = inw(0x1f0);
        u32 hi = inw(0x1f0);
        u32 w = lo | (hi << 16);
        asm volatile("movl %0, %1" : : "r"(w), "m"(dst[i]) : "memory");
    }
    serial_debug_putc('J');
    /*
     * Restore real-mode IVT; plant INT13/10/16; far-jump to boot at 0000:7C00.
     * Force dword stores via asm (gcc may split u32* stores into halfwords).
     */
    {
        static volatile u8 rmidt[8] = {
            0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa
        };
        u32 v13 = 0xF000E3FE, v10 = 0xF000F065, v16 = 0xF000E82E;
        asm volatile("movl %0, 0x4c" : : "r"(v13) : "memory");
        asm volatile("movl %0, 0x40" : : "r"(v10) : "memory");
        asm volatile("movl %0, 0x58" : : "r"(v16) : "memory");
        asm volatile(
            "invd\\n"
            "lidtl %0\\n"
            "movl $0x7c00, %%esp\\n"
            "movb $0x80, %%dl\\n"
            "movl %%cr0, %%eax\\n"
            "andl $~1, %%eax\\n"
            "movl %%eax, %%cr0\\n"
            ".byte 0x66, 0xea, 0x00, 0x7c, 0x00, 0x00\\n"
            :
            : "m"(rmidt[0])
            : "eax", "edx", "cc", "memory");
    }
}"""
assert old_sb in t, "startBoot missing"
t = t.replace(old_sb, new_sb, 1)

old_mi = """static void
maininit(void)
{
    // Initialize internal interfaces.
    interface_init();

    // Setup platform devices.
    platform_hardware_setup();

    // Start hardware initialization (if threads allowed during optionroms)
    if (threads_during_optionroms())
        device_hardware_setup();

    // Run vga option rom
    vgarom_setup();
    sercon_setup();
    enable_vga_console();

    // Do hardware initialization (if running synchronously)
    if (!threads_during_optionroms()) {
        device_hardware_setup();
        wait_threads();
    }

    // Run option roms
    optionrom_setup();

    // Allow user to modify overall boot order.
    interactive_bootmenu();
    wait_threads();

    // Prepare for boot.
    prepareboot();

    // Write protect bios memory.
    make_bios_readonly();

    // Invoke int 19 to start boot process.
    startBoot();
}"""
new_mi = """static void
maininit(void)
{
    /* openx86: minimal maininit */
    serial_debug_putc('M');
    ivt_init();
    serial_debug_putc('N');
    bda_init();
    kbd_init();
    int10text_init();
    serial_debug_putc('O');
    dma_setup();
    pic_setup();
    timer_setup();
    /* openx86: skip clock_setup/IRQ0 (reboot) and IRQ1 until 8042 ready */
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
}"""
assert old_mi in t, "maininit missing"
t = t.replace(old_mi, new_mi, 1)

old_hp = """void VISIBLE32FLAT
handle_post(void)
{
    if (!CONFIG_QEMU && !CONFIG_COREBOOT)
        return;

    serial_debug_preinit();
    debug_banner();

    // Check if we are running under Xen.
    xen_preinit();

    // Allow writes to modify bios area (0xf0000)
    make_bios_writable();

    // Now that memory is read/writable - start post process.
    dopost();
}"""
new_hp = """void VISIBLE32FLAT
handle_post(void)
{
    if (!CONFIG_QEMU && !CONFIG_COREBOOT)
        return;

    irq_disable(); /* openx86: early cli */
    asm volatile(\"movl $0x0008ff00, %%esp\" ::: \"esp\");
    serial_debug_preinit();
    debug_banner();

    /* openx86: call maininit directly from flat handle_post */
    serial_debug_putc('H');
    PlatformRunningOn |= PF_QEMU;
    RamSize = 640 * 1024;
    HaveRunPost = 1;
    maininit();
    for (;;)
        hlt();

    // Keep post/reloc linkage for ROM layout stability.
    xen_preinit();
    make_bios_writable();
    dopost();
}"""
assert old_hp in t, "handle_post missing"
t = t.replace(old_hp, new_hp, 1)

if "int10text_init" not in t.split("maininit")[0]:
    t = t.replace(
        '#include "util.h" // kbd_init\n',
        '#include "util.h" // kbd_init\nvoid int10text_init(void);\n',
        1,
    )

p.write_text(t)
print("OK lines", len(t.splitlines()))
