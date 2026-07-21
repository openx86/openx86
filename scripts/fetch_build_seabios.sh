#!/usr/bin/env sh
# Fetch and build SeaBIOS into artifacts/seabios/bios.bin (128KiB image).
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${SEABIOS_OUT_DIR:-$ROOT/artifacts/seabios}"
SRC_DIR="${SEABIOS_SRC_DIR:-$OUT_DIR/src}"
REPO_URL="${SEABIOS_REPO:-https://github.com/coreboot/seabios.git}"
REPO_REF="${SEABIOS_REF:-rel-1.16.3}"

mkdir -p "$OUT_DIR"

if [ ! -d "$SRC_DIR/.git" ]; then
  echo "Cloning SeaBIOS $REPO_REF ..."
  rm -rf "$SRC_DIR"
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$SRC_DIR"
else
  echo "Using existing SeaBIOS tree: $SRC_DIR"
  # Reset tracked sources so patches apply cleanly
  git -C "$SRC_DIR" checkout -- src/ || true
fi

cat >"$SRC_DIR/.config" <<'EOF'
CONFIG_COREBOOT=n
CONFIG_QEMU=y
CONFIG_QEMU_HARDWARE=y
CONFIG_DEBUG_LEVEL=1
CONFIG_DEBUG_SERIAL=y
CONFIG_DEBUG_SERIAL_PORT=0x3f8
CONFIG_ATA=y
CONFIG_ATA_DMA=n
CONFIG_ATA_PIO32=y
CONFIG_FLOPPY=n
CONFIG_VIRUSCHECKSUM=n
CONFIG_BOOTMENU=n
CONFIG_BOOTORDER=n
CONFIG_CPUID=y
CONFIG_THREADS=n
CONFIG_USB=n
CONFIG_USB_UHCI=n
CONFIG_USB_OHCI=n
CONFIG_USB_EHCI=n
CONFIG_USB_XHCI=n
CONFIG_USB_MSC=n
CONFIG_USB_UAS=n
CONFIG_USB_HUB=n
CONFIG_USB_HID=n
CONFIG_PVSCSI=n
CONFIG_ESP=n
CONFIG_MEGASAS=n
CONFIG_MPT=n
CONFIG_LSI=n
CONFIG_AHCI=n
CONFIG_SDCARD=n
CONFIG_NVME=n
CONFIG_VIRTIO=n
CONFIG_VIRTIO_PCI=n
CONFIG_VIRTIO_MMIO=n
CONFIG_VIRTIO_BLK=n
CONFIG_VIRTIO_SCSI=n
CONFIG_XEN=n
CONFIG_TPM=n
CONFIG_TCGBIOS=n
CONFIG_OPTIONROMS=y
CONFIG_OPTIONROMS_DEPLOYED=n
CONFIG_VGAHOOKS=y
CONFIG_ROM_SIZE=128
EOF

echo "Building SeaBIOS ..."
python3 - "$SRC_DIR" <<'PY'
from pathlib import Path
import sys
src = Path(sys.argv[1])

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

# serialio: skip %x
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

# serial flush nop
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

# banner: plain dprintf only (no %s)
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

# shadow: skip PAM
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

# qemu_preinit stub
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

# malloc_preinit empty
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

# reloc_preinit: fixed-address relocate (no malloc / no %p)
patch(
    "src/post.c",
    """void __noreturn
reloc_preinit(void *f, void *arg)
{
    void (*func)(void *) __noreturn = f;
    if (!CONFIG_RELOCATE_INIT)
        func(arg);

    // Allocate space for init code.
    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);
    u32 codealign = SYMBOL(_reloc_min_align);
    void *codedest = memalign_tmp(codealign, initsize);
    void *codesrc = VSYMBOL(code32init_start);
    if (!codedest)
        panic(\"No space for init relocation.\\n\");

    // Copy code and update relocs (init absolute, init relative, and runtime)
    dprintf(1, \"Relocating init from %p to %p (size %d)\\n\"
            , codesrc, codedest, initsize);
    s32 delta = codedest - codesrc;
    memcpy(codedest, codesrc, initsize);
    updateRelocs(codedest, VSYMBOL(_reloc_abs_start), VSYMBOL(_reloc_abs_end)
                 , delta);
    updateRelocs(codedest, VSYMBOL(_reloc_rel_start), VSYMBOL(_reloc_rel_end)
                 , -delta);
    updateRelocs(VSYMBOL(code32flat_start), VSYMBOL(_reloc_init_start)
                 , VSYMBOL(_reloc_init_end), delta);
    if (f >= codesrc && f < VSYMBOL(code32init_end))
        func = f + delta;

    // Call function in relocated code.
    barrier();
    func(arg);
}""",
    """void __noreturn
reloc_preinit(void *f, void *arg)
{
    /* openx86: fixed-address reloc (no malloc/%p) */
    void (*func)(void *) __noreturn = f;
    u32 initsize = SYMBOL(code32init_end) - SYMBOL(code32init_start);
    u32 codealign = SYMBOL(_reloc_min_align);
    void *codesrc = VSYMBOL(code32init_start);
    u32 dest = 0x00030000;
    dest = (dest + codealign - 1) & ~(codealign - 1);
    void *codedest = (void*)dest;
    s32 delta = (s32)codedest - (s32)codesrc;
    memcpy(codedest, codesrc, initsize);
    updateRelocs(codedest, VSYMBOL(_reloc_abs_start), VSYMBOL(_reloc_abs_end)
                 , delta);
    updateRelocs(codedest, VSYMBOL(_reloc_rel_start), VSYMBOL(_reloc_rel_end)
                 , -delta);
    updateRelocs(VSYMBOL(code32flat_start), VSYMBOL(_reloc_init_start)
                 , VSYMBOL(_reloc_init_end), delta);
    if (f >= codesrc && f < VSYMBOL(code32init_end))
        func = (void*)((u8*)f + delta);
    dprintf(1, \"R\\n\");
    barrier();
    func(arg);
    for (;;)
        hlt();
}""",
    "openx86: fixed-address reloc",
)

# code_mutable_preinit: skip RTC (HaveRunPost only)
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

# maininit minimal
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
    dprintf(1, \"M\\n\");
    ivt_init();
    dprintf(1, \"N\\n\");
    bda_init();
    dprintf(1, \"O\\n\");
    dma_setup();
    pic_setup();
    timer_setup();
    clock_setup();
    dprintf(1, \"P\\n\");
    block_setup();
    dprintf(1, \"Q\\n\");
    prepareboot();
    dprintf(1, \"T\\n\");
    startBoot();
    dprintf(1, \"!\\n\");
    irq_disable();
    for (;;)
        hlt();
    // Initialize internal interfaces.
    interface_init();
""",
    "openx86: minimal maininit",
)

# handle_post early cli + crumb
patch(
    "src/post.c",
    """    serial_debug_preinit();
    debug_banner();
""",
    """    irq_disable(); /* openx86: early cli */
    serial_debug_preinit();
    debug_banner();
    dprintf(1, \"B\\n\");
""",
    "openx86: early cli",
)
PY

make -C "$SRC_DIR" PYTHON="${PYTHON:-python3}" olddefconfig
make -C "$SRC_DIR" PYTHON="${PYTHON:-python3}" -j"$(nproc 2>/dev/null || echo 2)"

if [ -f "$SRC_DIR/out/bios.bin" ]; then
  cp -f "$SRC_DIR/out/bios.bin" "$OUT_DIR/bios.bin"
elif [ -f "$SRC_DIR/out/rom.bin" ]; then
  cp -f "$SRC_DIR/out/rom.bin" "$OUT_DIR/bios.bin"
else
  echo "error: SeaBIOS build did not produce out/bios.bin" >&2
  exit 1
fi

SIZE=$(wc -c <"$OUT_DIR/bios.bin" | tr -d ' ')
if [ "$SIZE" -gt 131072 ]; then
  tail -c 131072 "$OUT_DIR/bios.bin" >"$OUT_DIR/bios.bin.tmp"
  mv "$OUT_DIR/bios.bin.tmp" "$OUT_DIR/bios.bin"
elif [ "$SIZE" -lt 131072 ]; then
  dd if=/dev/zero bs=1 count=$((131072 - SIZE)) >>"$OUT_DIR/bios.bin" 2>/dev/null || \
    truncate -s 131072 "$OUT_DIR/bios.bin"
fi

echo "SeaBIOS ready: $OUT_DIR/bios.bin ($(wc -c <"$OUT_DIR/bios.bin" | tr -d ' ') bytes)"

# Minimal openx86 DOS bring-up ROM (used by tb/dos_boot_tb.sv)
python3 "$ROOT/scripts/build_openx86_dos_bios.py" "$OUT_DIR/dos_bios.bin"
echo "DOS BIOS ready: $OUT_DIR/dos_bios.bin"
