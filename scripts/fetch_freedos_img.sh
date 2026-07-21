#!/usr/bin/env sh
# Fetch a FreeDOS bootable 1.44MB floppy image into artifacts/freedos/disk.img
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${FREEDOS_OUT_DIR:-$ROOT/artifacts/freedos}"
mkdir -p "$OUT_DIR"
OUT_IMG="$OUT_DIR/disk.img"

# Official FreeDOS 1.3 LiveCD boot floppy (FD13BOOT.IMG) mirrored via ibiblio
URL="${FREEDOS_IMG_URL:-https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-FloppyEdition.zip}"

TMPDIR_FD="${TMPDIR:-/tmp}/openx86_freedos_$$"
mkdir -p "$TMPDIR_FD"
trap 'rm -rf "$TMPDIR_FD"' EXIT INT TERM

echo "Downloading FreeDOS floppy edition ..."
if command -v curl >/dev/null 2>&1; then
  curl -L --fail -o "$TMPDIR_FD/fd.zip" "$URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TMPDIR_FD/fd.zip" "$URL"
else
  echo "error: need curl or wget to fetch FreeDOS image" >&2
  exit 127
fi

echo "Extracting boot floppy image ..."
python3 - <<PY
import zipfile, pathlib, sys
zpath = pathlib.Path("$TMPDIR_FD/fd.zip")
out = pathlib.Path("$TMPDIR_FD/unz")
out.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(zpath) as zf:
    zf.extractall(out)
print("extracted to", out)
PY
# Prefer classic 1.44M boot floppy names
IMG=""
for cand in \
  "$TMPDIR_FD/unz/FD13BOOT.IMG" \
  "$TMPDIR_FD/unz"/*/FD13BOOT.IMG \
  "$TMPDIR_FD/unz"/*.img \
  "$TMPDIR_FD/unz"/*.IMG \
  "$TMPDIR_FD/unz"/*/*.img \
  "$TMPDIR_FD/unz"/*/*.IMG
do
  if [ -f "$cand" ]; then
    IMG="$cand"
    break
  fi
done

if [ -z "$IMG" ]; then
  # Prefer names containing BOOT / FLOPPY
  IMG=$(find "$TMPDIR_FD/unz" -type f \( -iname '*boot*.img' -o -iname '*floppy*.img' -o -iname '*.img' \) | head -n 1 || true)
fi

if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
  echo "error: no .img found in FreeDOS zip; listing:" >&2
  find "$TMPDIR_FD/unz" -type f | head -n 50 >&2
  exit 1
fi

cp -f "$IMG" "$OUT_IMG"
SIZE=$(wc -c <"$OUT_IMG" | tr -d ' ')
echo "FreeDOS disk ready: $OUT_IMG ($SIZE bytes)"

# Pad to 1.44MiB if smaller (IDE BRAM expects up to 2880 sectors)
TARGET=$((512 * 2880))
if [ "$SIZE" -lt "$TARGET" ]; then
  echo "Padding disk image to $TARGET bytes"
  dd if=/dev/zero bs=1 count=$((TARGET - SIZE)) >>"$OUT_IMG" 2>/dev/null || \
    truncate -s "$TARGET" "$OUT_IMG"
fi
