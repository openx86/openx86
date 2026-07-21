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
CONFIG_ATA_PIO32=n
CONFIG_FLOPPY=n
CONFIG_FLASH_FLOPPY=n
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
CONFIG_ENTRY_EXTRASTACK=n
EOF

echo "Building SeaBIOS ..."
# Known-good openx86 patches (call-in-place reloc)
python3 "$ROOT/scripts/_patch_seabios_good.py" "$SRC_DIR"

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

# 16-bit INT13 ATA stub at F000:9000 (skip SeaBIOS 16→32 transition)
python3 "$ROOT/scripts/_gen_int13_stub.py"
python3 "$ROOT/scripts/_embed_int13_stub_rom.py"

# Minimal openx86 DOS bring-up ROM (used by tb/dos_boot_tb.sv)
python3 "$ROOT/scripts/build_openx86_dos_bios.py" "$OUT_DIR/dos_bios.bin"
echo "DOS BIOS ready: $OUT_DIR/dos_bios.bin"
