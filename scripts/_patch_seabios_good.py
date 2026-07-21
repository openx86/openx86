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
        print("skip (missing pattern):", name)
        return
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
    /* openx86: raw OUT banner — avoid bvprintf/putc jmp*(%eax) */
    serial_debug_putc('S');
    serial_debug_putc('e');
    serial_debug_putc('a');
    serial_debug_putc('B');
    serial_debug_putc('I');
    serial_debug_putc('O');
    serial_debug_putc('S');
    serial_debug_putc('\\n');
}""",
    "openx86: plain banner only",
)

patch(
    "src/output.c",
    """static void
putc(struct putcinfo *action, char c)
{
    if (MODESEGMENT) {
        // Only debugging output supported in segmented mode.
        debug_putc(action, c);
        return;
    }

    void (*func)(struct putcinfo *info, char c) = GET_GLOBAL(action->func);
    func(action, c);
}
""",
    """static void
putc(struct putcinfo *action, char c)
{
    /* openx86: avoid GET_GLOBAL(action->func) indirect call (bad F-seg ptr) */
    debug_putc(action, c);
    return;
    if (MODESEGMENT) {
        // Only debugging output supported in segmented mode.
        debug_putc(action, c);
        return;
    }

    void (*func)(struct putcinfo *info, char c) = GET_GLOBAL(action->func);
    func(action, c);
}
""",
    "openx86: putc direct debug",
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
    /* openx86: minimal zones in conventional RAM only (no >1MB — sim RAM).
     * ZoneTmpLow first — alloc_add bookkeeping allocates detail from it. */
    ASSERT32FLAT();
    memset(&ZoneFSeg, 0, sizeof(ZoneFSeg));
    memset(&ZoneTmpHigh, 0, sizeof(ZoneTmpHigh));
    memset(&ZoneTmpLow, 0, sizeof(ZoneTmpLow));
    memset(&ZoneLow, 0, sizeof(ZoneLow));
    memset(&ZoneHigh, 0, sizeof(ZoneHigh));
    alloc_add(&ZoneTmpLow, BUILD_STACK_ADDR, BUILD_EBDA_MINIMUM);
    alloc_add(&ZoneFSeg, 0x90000, 0x9f000);
    return;
    dprintf(3, \"malloc preinit\\n\");
""",
    "openx86: minimal malloc zones",
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
    /* openx86: skip clock_setup (IRQ0) */
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
    serial_debug_putc('A'); /* openx86: after banner */
""",
    "openx86: early cli",
)

# malloc_preinit skipped in dopost; malloc_palloc uses bump pool (patched below).
patch(
    "src/post.c",
    """    qemu_preinit();
    coreboot_preinit();
    malloc_preinit();

    // Relocate initialization code and call maininit().
""",
    """    qemu_preinit();
    coreboot_preinit();
    /* openx86: skip zone alloc_add — use bump malloc_palloc */
    // malloc_preinit();

    // Relocate initialization code and call maininit().
""",
    "openx86: skip malloc_preinit in dopost",
)

patch(
    "src/malloc.c",
    """u32
malloc_palloc(struct zone_s *zone, u32 size, u32 align)
{
    ASSERT32FLAT();
    if (!size)
        return 0;

    // Find and reserve space for main allocation
    struct allocdetail_s tempdetail;
    tempdetail.handle = MALLOC_DEFAULT_HANDLE;
    u32 data = alloc_new(zone, size, align, &tempdetail.datainfo);
""",
    """u32
malloc_palloc(struct zone_s *zone, u32 size, u32 align)
{
    /* openx86: bump pool; pointer in low RAM (F-seg statics not reliable) */
    u32 *ox_bump = (u32 *)0x4fff0;
    const u32 ox_end = 0x8f000;
    (void)zone;
    ASSERT32FLAT();
    if (!size)
        return 0;
    if (!align)
        align = MALLOC_MIN_ALIGN;
    if (*ox_bump < 0x50000 || *ox_bump >= ox_end)
        *ox_bump = 0x50000;
    u32 data = ALIGN(*ox_bump, align);
    if (data < *ox_bump || data + size > ox_end || data + size < data)
        return 0;
    *ox_bump = data + size;
    return data;
    // Find and reserve space for main allocation
    struct allocdetail_s tempdetail;
    tempdetail.handle = MALLOC_DEFAULT_HANDLE;
    data = alloc_new(zone, size, align, &tempdetail.datainfo);
""",
    "openx86: bump malloc_palloc",
)

patch(
    "src/hw/serialio.c",
    """// Write a character to the serial port.
static void
serial_debug(char c)
{
    if (!CONFIG_DEBUG_SERIAL && (!CONFIG_DEBUG_SERIAL_MMIO || MODESEGMENT))
        return;
    int timeout = DEBUG_TIMEOUT;
    while ((serial_debug_read(SEROFF_LSR) & 0x20) != 0x20)
        if (!timeout--)
            // Ran out of time.
            return;
    serial_debug_write(SEROFF_DATA, c);
}""",
    """// Write a character to the serial port.
static void
serial_debug(char c)
{
    if (!CONFIG_DEBUG_SERIAL && (!CONFIG_DEBUG_SERIAL_MMIO || MODESEGMENT))
        return;
    /* openx86: skip THRE poll — OUT THR directly */
    serial_debug_write(SEROFF_DATA, c);
}""",
    "openx86: skip THRE poll",
)

patch(
    "src/e820map.c",
    """// Remove an entry from the e820_list.
static void
remove_e820(int i)
{
    e820_count--;
    memmove(&e820_list[i], &e820_list[i+1]
            , sizeof(e820_list[0]) * (e820_count - i));
}

// Insert an entry in the e820_list at the given position.
static void
insert_e820(int i, u64 start, u64 size, u32 type)
{
    if (e820_count >= BUILD_MAX_E820) {
        warn_noalloc();
        return;
    }

    memmove(&e820_list[i+1], &e820_list[i]
            , sizeof(e820_list[0]) * (e820_count - i));
    e820_count++;
    struct e820entry *e = &e820_list[i];
    e->start = start;
    e->size = size;
    e->type = type;
}
""",
    """// Remove an entry from the e820_list.
static void
remove_e820(int i)
{
    int n;
    /* openx86: avoid memmove PUSH prolog */
    e820_count--;
    for (n = i; n < e820_count; n++)
        e820_list[n] = e820_list[n + 1];
}

// Insert an entry in the e820_list at the given position.
static void
insert_e820(int i, u64 start, u64 size, u32 type)
{
    if (e820_count >= BUILD_MAX_E820) {
        warn_noalloc();
        return;
    }
    /* openx86: append-only — avoid memmove + multi-PUSH prolog (sticky ESP) */
    if (i != e820_count)
        i = e820_count;
    e820_list[i].start = start;
    e820_list[i].size = size;
    e820_list[i].type = type;
    e820_count++;
}
""",
    "openx86: append-only e820 insert",
)

patch(
    "src/disk.c",
    """// INT 13h Fixed Disk Services Entry Point
void VISIBLE16
handle_13(struct bregs *regs)
{
    debug_enter(regs, DEBUG_HDL_13);
    u8 extdrive = regs->dl;

    if (CONFIG_CDROM_EMU) {
        if (regs->ah == 0x4b) {
            cdemu_134b(regs);
            return;
        }
        if (GET_LOW(CDEmu.media)) {
            u8 emudrive = GET_LOW(CDEmu.emulated_drive);
            if (extdrive == emudrive) {
                // Access to an emulated drive.
                struct drive_s *cdemu_gf = GET_GLOBAL(cdemu_drive_gf);
                if (regs->ah > 0x16) {
                    // Only old-style commands supported.
                    disk_13XX(regs, cdemu_gf);
                    return;
                }
                disk_13(regs, cdemu_gf);
                return;
            }
            if (extdrive < EXTSTART_CD && ((emudrive ^ extdrive) & 0x80) == 0)
                // Adjust id to make room for emulated drive.
                extdrive--;
        }
    }
    handle_legacy_disk(regs, extdrive);
}""",
    """// INT 13h Fixed Disk Services Entry Point
void VISIBLE16
handle_13(struct bregs *regs)
{
    /* openx86: ATA PIO for boot reads; keep legacy path for POST probes */
    if (regs->ah == 0x41) {
        regs->bx = 0xaa55;
        regs->cx = 0x0001;
        regs->ah = 0x21;
        set_success(regs);
        return;
    }
    if (regs->ah == 0x02 || regs->ah == 0x42) {
        u32 lba, count, s;
        void *buf;
        serial_debug_putc('R');
        if (regs->ah == 0x42) {
            struct int13ext_s *p = (void *)(regs->si + 0);
            count = GET_FARVAR(regs->ds, p->count);
            lba = GET_FARVAR(regs->ds, p->lba);
            buf = SEGOFF_TO_FLATPTR(GET_FARVAR(regs->ds, p->data));
            if (!count) {
                disk_ret(regs, DISK_RET_SUCCESS);
                return;
            }
        } else {
            u8 cnt = regs->al;
            u16 cylinder = regs->ch | ((((u16)regs->cl) << 2) & 0x300);
            u16 sector = regs->cl & 0x3f;
            u16 head = regs->dh;
            /* FreeDOS BPB in artifacts/freedos: spt=15, heads=2 */
            u16 nls = 15, nlh = 2;
            if (!cnt || !sector || sector > nls || head >= nlh || cylinder >= 80) {
                disk_ret(regs, DISK_RET_EPARAM);
                return;
            }
            count = cnt;
            lba = ((((u32)cylinder * nlh) + head) * nls) + sector - 1;
            buf = MAKE_FLATPTR(regs->es, regs->bx);
        }
        for (s = 0; s < count; s++) {
            u32 l = lba + s;
            u8 st;
            int t;
            void *dst = (u8 *)buf + s * 512;
            outb(0xa0 | 0x40 | ((l >> 24) & 0xf), 0x1f6);
            outb(1, 0x1f2);
            outb(l, 0x1f3);
            outb(l >> 8, 0x1f4);
            outb(l >> 16, 0x1f5);
            outb(0x20, 0x1f7);
            for (t = 0; t < 256; t++) {
                st = inb(0x1f7);
                if (!(st & 0x80) && (st & 0x08))
                    break;
            }
            if (t >= 256 || !(st & 0x08)) {
                serial_debug_putc('r');
                if (regs->ah == 0x02)
                    regs->al = s;
                disk_ret(regs, DISK_RET_EBADTRACK);
                return;
            }
            insw_fl(0x1f0, dst, 256);
        }
        serial_debug_putc('K');
        if (regs->ah == 0x02)
            regs->al = count;
        else {
            struct int13ext_s *p = (void *)(regs->si + 0);
            SET_FARVAR(regs->ds, p->count, count);
        }
        disk_ret(regs, DISK_RET_SUCCESS);
        return;
    }
    debug_enter(regs, DEBUG_HDL_13);
    u8 extdrive = regs->dl;

    if (CONFIG_CDROM_EMU) {
        if (regs->ah == 0x4b) {
            cdemu_134b(regs);
            return;
        }
        if (GET_LOW(CDEmu.media)) {
            u8 emudrive = GET_LOW(CDEmu.emulated_drive);
            if (extdrive == emudrive) {
                // Access to an emulated drive.
                struct drive_s *cdemu_gf = GET_GLOBAL(cdemu_drive_gf);
                if (regs->ah > 0x16) {
                    // Only old-style commands supported.
                    disk_13XX(regs, cdemu_gf);
                    return;
                }
                disk_13(regs, cdemu_gf);
                return;
            }
            if (extdrive < EXTSTART_CD && ((emudrive ^ extdrive) & 0x80) == 0)
                // Adjust id to make room for emulated drive.
                extdrive--;
        }
    }
    handle_legacy_disk(regs, extdrive);
}""",
    "openx86: direct ATA INT13",
)


patch(
    "src/hw/ata.c",
    """#include "output.h" // dprintf
""",
    """#include "output.h" // dprintf
#include "hw/serialio.h" // serial_debug_putc
""",
    "openx86: ata serialio include",
)

patch(
    "src/hw/ata.c",
    """    dprintf(1, "ATA controller %d at %x/%x/%x (irq %d dev %x)\n"
            , ataid, port1, port2, master, irq, chan_gf->pci_bdf);""",
    """    /* openx86: avoid puthex jump-table (FF /4 SIB) hang after first %x */
    (void)ataid; (void)port1; (void)port2; (void)master; (void)irq;
    serial_debug_putc('A');
    serial_debug_putc('T');
    serial_debug_putc('A');
    serial_debug_putc('\n');""",
    "openx86: avoid puthex jump-table",
)


patch(
    "src/hw/ata.c",
    """static void
ata_detect(void *data)
{
    struct ata_channel_s *chan_gf = data;
""",
    """static void
ata_detect(void *data)
{
    /* openx86: skip slow IDE probe/timeouts — boot uses INT13 ATA PIO */
    (void)data;
    serial_debug_putc('D');
    return;
    struct ata_channel_s *chan_gf = data;
""",
    "openx86: skip slow IDE probe",
)

patch(
    "src/hw/ata.c",
    """void
ata_setup(void)
{
    ASSERT32FLAT();
    if (!CONFIG_ATA)
        return;

    dprintf(3, \"init hard drives\\n\");

    SpinupEnd = timer_calc(IDE_TIMEOUT);
    ata_scan();

    SET_BDA(disk_control_byte, 0xc0);

    enable_hwirq(14, FUNC16(entry_76));
}""",
    """void
ata_setup(void)
{
    /* openx86: skip ata_scan/timer — INT13 ATA PIO is enough for boot */
    ASSERT32FLAT();
    if (!CONFIG_ATA)
        return;
    serial_debug_putc('a');
    SET_BDA(disk_control_byte, 0xc0);
    enable_hwirq(14, FUNC16(entry_76));
    serial_debug_putc('b');
    return;
    dprintf(3, \"init hard drives\\n\");

    SpinupEnd = timer_calc(IDE_TIMEOUT);
    ata_scan();

    SET_BDA(disk_control_byte, 0xc0);

    enable_hwirq(14, FUNC16(entry_76));
}""",
    "openx86: skip ata_scan/timer",
)

patch(
    "src/block.c",
    """#include "output.h" // dprintf
""",
    """#include "output.h" // dprintf
#include "hw/serialio.h" // serial_debug_putc
""",
    "openx86: block serialio include",
)

patch(
    "src/block.c",
    """block_setup(void)
{
    floppy_setup();
    ata_setup();
    ahci_setup();
    sdcard_setup();
    ramdisk_setup();
    virtio_blk_setup();
    virtio_scsi_setup();
    lsi_scsi_setup();
    esp_scsi_setup();
    megasas_setup();
    pvscsi_setup();
    mpt_scsi_setup();
    nvme_setup();
}""",
    """block_setup(void)
{
    /* openx86: only minimal ATA IRQ; skip PCI/SCSI/virtio probes */
    serial_debug_putc('B');
    ata_setup();
    serial_debug_putc('C');
    return;
    floppy_setup();
    ata_setup();
    ahci_setup();
    sdcard_setup();
    ramdisk_setup();
    virtio_blk_setup();
    virtio_scsi_setup();
    lsi_scsi_setup();
    esp_scsi_setup();
    megasas_setup();
    pvscsi_setup();
    mpt_scsi_setup();
    nvme_setup();
}""",
    "openx86: minimal block_setup",
)

patch(
    "src/post.c",
    """#include "util.h" // kbd_init
#include "tcgbios.h" // tpm_*
""",
    """#include "util.h" // kbd_init
#include "tcgbios.h" // tpm_*
#include "x86.h" // inb/outb/inw
""",
    "openx86: post x86 include",
)

patch(
    "src/post.c",
    """void
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
}""",
    """void
prepareboot(void)
{
    /* openx86: skip malloc_prepboot/bcv (zones never alloc_add'd) */
    HaveRunPost = 2;
    return;
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
}""",
    "openx86: minimal prepareboot",
)

patch(
    "src/post.c",
    """// Begin the boot process by invoking an int0x19 in 16bit mode.
void VISIBLE32FLAT
startBoot(void)
{
    // Clear low-memory allocations (required by PMM spec).
    memset((void*)BUILD_STACK_ADDR, 0, BUILD_EBDA_MINIMUM - BUILD_STACK_ADDR);

    dprintf(3, "Jump to int19\\n");
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    call16_int(0x19, &br);
}""",
    """// Begin the boot process by invoking an int0x19 in 16bit mode.
void VISIBLE32FLAT
startBoot(void)
{
    /* openx86: do not wipe BUILD_STACK_ADDR..EBDA (clears live stack) */
    /* Direct ATA READ LBA0 → 0x7C00, then far jump (skip fragile call16_int).
     * FreeDOS then uses INT13 (handle_13 ATA PIO) for KERNEL.SYS. */
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
    /* Halfword stores to 7C00; then absolute dword copy to 1FE0:7C00.
     * Phys = (0x1FE0<<4)+0x7C00 = 0x27A00 (NOT 0x27C00).
     * Avoid base+disp32 — AGU currently drops that disp.
     * NOP FreeDOS REP MOVSW (F3 A5 @ +0x53) via dword stores; never enter
     * 0000:7C00 (broken MOVS would wipe the relocated image). */
    {
        u16 *p = (u16 *)0x7C00;
        for (i = 0; i < 256; i++)
            p[i] = inw(0x1f0);
        for (i = 0; i < 128; i++) {
            u32 w = ((u32 *)0x7C00)[i];
            u32 *d = (u32 *)(0x27A00 + (i << 2));
            asm volatile("movl %0, (%1)" : : "r"(w), "r"(d) : "memory");
        }
        /* 7C50: B9 00 01 F3 A5 EA 5E 7C -> B9 00 01 90 90 EA 5E 7C */
        asm volatile("movl $0x900100B9, (%0)" : : "r"((u32 *)0x7C50) : "memory");
        asm volatile("movl $0x7C5EEA90, (%0)" : : "r"((u32 *)0x7C54) : "memory");
        asm volatile("movl $0x900100B9, (%0)" : : "r"((u32 *)0x27A50) : "memory");
        asm volatile("movl $0x7C5EEA90, (%0)" : : "r"((u32 *)0x27A54) : "memory");
    }
    serial_debug_putc('J');
    /*
     * Plant 16-bit INT13 ATA stub at 0000:9000 (skip SeaBIOS 16->32 transition),
     * restore IVT INT10/16; far-jump to FreeDOS 1FE0:7C5E.
     */
    {
        static u8 stub[] = {
            0x55, 0x89, 0xe5, 0x80, 0xfc, 0x00, 0x74, 0x1e, 0x80, 0xfc, 0x41, 0x74,
            0x21, 0x80, 0xfc, 0x08, 0x74, 0x2a, 0x80, 0xfc, 0x02, 0x74, 0x78, 0x80,
            0xfc, 0x42, 0x0f, 0x84, 0xeb, 0x00, 0xb4, 0x01, 0x83, 0x4e, 0x06, 0x01,
            0x5d, 0xcf, 0x30, 0xe4, 0x83, 0x66, 0x06, 0xfe, 0x5d, 0xcf, 0xbb, 0x55,
            0xaa, 0xb9, 0x01, 0x00, 0xb4, 0x21, 0x83, 0x66, 0x06, 0xfe, 0x5d, 0xcf,
            0xb9, 0x0f, 0x4f, 0xba, 0x01, 0x01, 0x30, 0xe4, 0x83, 0x66, 0x06, 0xfe,
            0x5d, 0xcf, 0xb0, 0xe0, 0xba, 0xf6, 0x01, 0xee, 0xb0, 0x01, 0xba, 0xf2,
            0x01, 0xee, 0x89, 0xf8, 0xba, 0xf3, 0x01, 0xee, 0x88, 0xe0, 0xba, 0xf4,
            0x01, 0xee, 0x30, 0xc0, 0xba, 0xf5, 0x01, 0xee, 0xb0, 0x20, 0xba, 0xf7,
            0x01, 0xee, 0xb9, 0x00, 0x02, 0xec, 0xa8, 0x80, 0x75, 0x04, 0xa8, 0x08,
            0x75, 0x04, 0xe2, 0xf5, 0xf9, 0xc3, 0xb9, 0x00, 0x01, 0xba, 0xf0, 0x01,
            0xed, 0x26, 0x89, 0x07, 0x83, 0xc3, 0x02, 0xe2, 0xf4, 0xf8, 0xc3, 0x50,
            0x53, 0x51, 0x52, 0x56, 0x57, 0x06, 0xb0, 0x52, 0xba, 0xf8, 0x03, 0xee,
            0x8a, 0x46, 0xfe, 0x0f, 0xb6, 0xf0, 0x85, 0xf6, 0x74, 0x54, 0x8b, 0x4e,
            0xfa, 0x0f, 0xb6, 0xc5, 0x88, 0xcb, 0x80, 0xe3, 0xc0, 0xc0, 0xeb, 0x06,
            0x88, 0xdc, 0x89, 0xc7, 0x88, 0xc8, 0x24, 0x3f, 0x0f, 0xb6, 0xc8, 0x85,
            0xc9, 0x74, 0x37, 0x8b, 0x46, 0xf8, 0x0f, 0xb6, 0xdc, 0x89, 0xf8, 0x01,
            0xc0, 0x01, 0xd8, 0xba, 0x0f, 0x00, 0xf7, 0xe2, 0x01, 0xc8, 0x48, 0x89,
            0xc7, 0x8b, 0x5e, 0xfc, 0xe8, 0x6b, 0xff, 0x72, 0x19, 0x47, 0x4e, 0x75,
            0xf7, 0xb0, 0x4b, 0xba, 0xf8, 0x03, 0xee, 0x07, 0x5f, 0x5e, 0x5a, 0x59,
            0x5b, 0x58, 0x30, 0xe4, 0x83, 0x66, 0x06, 0xfe, 0x5d, 0xcf, 0x07, 0x5f,
            0x5e, 0x5a, 0x59, 0x5b, 0x58, 0xb4, 0x04, 0x83, 0x4e, 0x06, 0x01, 0x5d,
            0xcf, 0x50, 0x53, 0x51, 0x52, 0x56, 0x57, 0x06, 0x1e, 0xb0, 0x52, 0xba,
            0xf8, 0x03, 0xee, 0x8b, 0x5e, 0xf6, 0x8b, 0x77, 0x02, 0x85, 0xf6, 0x74,
            0x16, 0x8b, 0x47, 0x04, 0x8b, 0x4f, 0x06, 0x8e, 0xc1, 0x8b, 0x7f, 0x08,
            0x89, 0xc3, 0xe8, 0x19, 0xff, 0x72, 0x1a, 0x47, 0x4e, 0x75, 0xf7, 0xb0,
            0x4b, 0xba, 0xf8, 0x03, 0xee, 0x1f, 0x07, 0x5f, 0x5e, 0x5a, 0x59, 0x5b,
            0x58, 0x30, 0xe4, 0x83, 0x66, 0x06, 0xfe, 0x5d, 0xcf, 0x1f, 0x07, 0x5f,
            0x5e, 0x5a, 0x59, 0x5b, 0x58, 0xb4, 0x04, 0x83, 0x4e, 0x06, 0x01, 0x5d,
            0xcf
        };
        /* Dword plant — byte stores are unreliable on this CPU path */
        {
            u32 i, n = (sizeof(stub) + 3) / 4;
            for (i = 0; i < n; i++) {
                u32 w = 0;
                u32 j;
                for (j = 0; j < 4; j++) {
                    u32 off = i * 4 + j;
                    if (off < sizeof(stub))
                        w |= ((u32)stub[off]) << (j * 8);
                }
                u32 *d = (u32 *)(0x9000 + (i << 2));
                asm volatile("movl %0, (%1)" : : "r"(w), "r"(d) : "memory");
            }
        }
        static volatile u8 rmidt[8] = {
            0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa
        };
        u32 v13 = 0xF0009000, v10 = 0xF000F065, v16 = 0xF000E82E;
        asm volatile("movl %0, 0x4c" : : "r"(v13) : "memory");
        asm volatile("movl %0, 0x40" : : "r"(v10) : "memory");
        asm volatile("movl %0, 0x58" : : "r"(v16) : "memory");
        asm volatile(
            "invd\\n"
            "lidtl %0\\n"
            "movb $0x80, %%dl\\n"
            "movl %%cr0, %%eax\\n"
            "andl $~1, %%eax\\n"
            "movl %%eax, %%cr0\\n"
            "movw $0x1FE0, %%ax\\n"
            "movw $0x7C00, %%bp\\n"
            ".byte 0x66, 0xea, 0x5e, 0x7c, 0xe0, 0x1f\\n"
            :
            : "m"(rmidt[0])
            : "eax", "edx", "cc", "memory");
    }
    return;
    // Clear low-memory allocations (required by PMM spec).
    memset((void*)BUILD_STACK_ADDR, 0, BUILD_EBDA_MINIMUM - BUILD_STACK_ADDR);

    dprintf(3, "Jump to int19\\n");
    struct bregs br;
    memset(&br, 0, sizeof(br));
    br.flags = F_IF;
    call16_int(0x19, &br);
}""",
    "openx86: direct ATA startBoot",
)

print("all patches applied")
