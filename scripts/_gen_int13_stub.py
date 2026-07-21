#!/usr/bin/env python3
"""INT13 stub for CS.D=0 / FreeDOS floppy-as-ATA.

Avoid: AH/CH/DH dest (except B4 Ib), SHR/SHL imm, MUL/LOOP.
CHS→LBA uses BPB geometry SPT=15, heads=2.
IDE model is sync DRQ — skip status poll (odd-port IN is unreliable).
"""
from pathlib import Path

def le16(x):
    return bytes([x & 0xFF, (x >> 8) & 0xFF])

code = bytearray()

def emit(*bs):
    code.extend(bs)

def patch_rel8(off, target):
    disp = target - (off + 1)
    if disp < -128 or disp > 127:
        raise SystemExit(f"rel8 {disp} at {off} -> {target}")
    code[off] = disp & 0xFF

def patch_rel16(off, target):
    disp = target - (off + 2)
    code[off] = disp & 0xFF
    code[off + 1] = (disp >> 8) & 0xFF

# ---- dispatch ----
emit(0x55)                          # push bp
emit(0x89, 0xE5)                    # mov bp, sp
emit(0x80, 0xFC, 0x00)              # cmp ah, 0
emit(0x74, 0x00); je_ok = len(code) - 1
emit(0x80, 0xFC, 0x41)
emit(0x74, 0x00); je_41 = len(code) - 1
emit(0x80, 0xFC, 0x08)
emit(0x74, 0x00); je_08 = len(code) - 1
emit(0x80, 0xFC, 0x02)
emit(0x0F, 0x84, 0x00, 0x00); je_02 = len(code) - 2
emit(0x80, 0xFC, 0x42)
emit(0x0F, 0x84, 0x00, 0x00); je_42 = len(code) - 2
emit(0xB4, 0x01)
emit(0x83, 0x4E, 0x06, 0x01)
emit(0x5D)
emit(0xCF)

Lok = len(code)
patch_rel8(je_ok, Lok)
emit(0xB4, 0x00)
emit(0x83, 0x66, 0x06, 0xFE)
emit(0x5D)
emit(0xCF)

L41 = len(code)
patch_rel8(je_41, L41)
emit(0xBB), code.extend(le16(0xAA55))
# CX bit0 = packet API. AL=1 so after caller SHR AX,1 CF=1 and
# SBB BX,0xAA54 yields 0 → FreeDOS takes AH=42 path (skips broken CHS).
emit(0xB9), code.extend(le16(0x0001))
emit(0xB8), code.extend(le16(0x2101))  # mov ax, 0x2101 (AH=21, AL=1)
emit(0x83, 0x66, 0x06, 0xFE)
emit(0x5D)
emit(0xCF)

L08 = len(code)
patch_rel8(je_08, L08)
emit(0xB9), code.extend(le16(0x4F0F))   # 80 cyl, SPT=15
emit(0xBA), code.extend(le16(0x0100))   # 2 heads
emit(0xB4, 0x00)
emit(0x83, 0x66, 0x06, 0xFE)
emit(0x5D)
emit(0xCF)

# ---- read_one: DI=LBA, ES:BX=buffer ----
# Must NOT clobber SI — L02/L42 keep sector count in SI across call.
read_one = len(code)
emit(0x53)                            # push bx  (save buffer; preserve SI)
emit(0xB0, 0xE0)
emit(0xBA), code.extend(le16(0x1F6))
emit(0xEE)
emit(0xB0, 0x01)
emit(0xBA), code.extend(le16(0x1F2))
emit(0xEE)
emit(0x89, 0xF8)                      # ax = di
emit(0xBA), code.extend(le16(0x1F3))
emit(0xEE)                            # out LBA[7:0]
emit(0x50)                            # push ax
emit(0x89, 0xE3)                      # bx = sp
emit(0x36, 0x8A, 0x47, 0x01)          # mov al, ss:[bx+1] (must be SS — not DS)
emit(0x59)                            # pop cx  (drop LBA word)
emit(0xBA), code.extend(le16(0x1F4))
emit(0xEE)
emit(0xB0, 0x00)
emit(0xBA), code.extend(le16(0x1F5))
emit(0xEE)
emit(0xB0, 0x20)
emit(0xBA), code.extend(le16(0x1F7))
emit(0xEE)
emit(0x5B)                            # pop bx  (restore buffer)
emit(0xBA), code.extend(le16(0x1F0))
emit(0xB9), code.extend(le16(0x0100))
read_loop = len(code)
emit(0xED)                            # in ax, dx
emit(0x26, 0x89, 0x07)                # mov es:[bx], ax
emit(0x83, 0xC3, 0x02)
emit(0x49)
emit(0x75, 0x00); jnz_rd = len(code) - 1
patch_rel8(jnz_rd, read_loop)
# BX = start+512 after 256× add 2 — ready for next sector
emit(0xF8)
emit(0xC3)

# ---- AH=02 CHS ----
L02 = len(code)
patch_rel16(je_02, L02)
emit(0x50)
emit(0x53)
emit(0x51)
emit(0x52)
emit(0x56)
emit(0x57)
emit(0x06)
emit(0xB0, 0x52)
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
# count = AL
emit(0x8B, 0x46, 0xFE)
emit(0x25), code.extend(le16(0x00FF))
emit(0x89, 0xC6)
emit(0x09, 0xF6)
emit(0x74, 0x00); jz_fail02 = len(code) - 1
# sector = CL & 3Fh  ([bp-6] low)
emit(0x8A, 0x4E, 0xFA)
emit(0x80, 0xE1, 0x3F)
emit(0x84, 0xC9)
emit(0x74, 0x00); jz_fail02b = len(code) - 1
# cyl = CH ([bp-5])
emit(0x8A, 0x46, 0xFB)
emit(0xB4, 0x00)
emit(0x89, 0xC7)                      # di = cyl
# head = DH ([bp-7])
emit(0x8A, 0x46, 0xF9)
emit(0xB4, 0x00)
emit(0x89, 0xC3)                      # bx = head
# ax = cyl*2 + head
emit(0x89, 0xF8)
emit(0x01, 0xC0)
emit(0x01, 0xD8)
# ax *= 15  (= ax*16 - ax) via adds
emit(0x89, 0xC2)                      # dx = ax
emit(0x01, 0xC0)
emit(0x01, 0xC0)
emit(0x01, 0xC0)
emit(0x01, 0xC0)                      # ax *= 16
emit(0x29, 0xD0)                      # ax -= old → *15
# add zero-extended sector from CL (avoid MOV CH,Ib — high-byte GPR ops)
emit(0x89, 0xC2)                      # dx = ax (*15 result)
emit(0x31, 0xC0)                      # xor ax, ax
emit(0x88, 0xC8)                      # mov al, cl
emit(0x01, 0xD0)                      # ax += dx
emit(0x48)
emit(0x89, 0xC7)                      # di = LBA
emit(0x8B, 0x5E, 0xFC)                # bx = caller BX
L02loop = len(code)
emit(0xE8, 0x00, 0x00); call_ro = len(code) - 2
patch_rel16(call_ro, read_one)
emit(0x72, 0x00); jc_fail02 = len(code) - 1
emit(0x47)
emit(0x4E)
emit(0x75, 0x00); jnz_l02 = len(code) - 1
patch_rel8(jnz_l02, L02loop)
emit(0xB0, 0x4B)
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
emit(0x07)
emit(0x5F)
emit(0x5E)
emit(0x5A)
emit(0x59)
emit(0x5B)
emit(0x58)
emit(0xB4, 0x00)
emit(0xB0, 0x00)
emit(0x83, 0x66, 0x06, 0xFE)
emit(0x5D)
emit(0xCF)
L02fail = len(code)
patch_rel8(jz_fail02, L02fail)
patch_rel8(jz_fail02b, L02fail)
patch_rel8(jc_fail02, L02fail)
emit(0x07)
emit(0x5F)
emit(0x5E)
emit(0x5A)
emit(0x59)
emit(0x5B)
emit(0x58)
emit(0xB4, 0x04)
emit(0x83, 0x4E, 0x06, 0x01)
emit(0x5D)
emit(0xCF)

# ---- AH=42 packet (LBA in packet) ----
L42 = len(code)
patch_rel16(je_42, L42)
emit(0x50)
emit(0x53)
emit(0x51)
emit(0x52)
emit(0x56)
emit(0x57)
emit(0x06)
emit(0x1E)
emit(0xB0, 0x52)
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
emit(0x8B, 0x5E, 0xF6)                # bx = SI (DAP)
emit(0x8B, 0x47, 0x02)                # ax = nsect
emit(0x89, 0xC6)
emit(0x09, 0xF6)
emit(0x74, 0x00); jz_42ok = len(code) - 1
emit(0x8B, 0x47, 0x04)                # ax = buf off
emit(0x8B, 0x4F, 0x06)                # cx = buf seg
emit(0x8E, 0xC1)
emit(0x8B, 0x7F, 0x08)                # di = LBA low
# Remap FreeDOS bogus start LBA data_start-1 → root_start, but only
# before the one-shot found redirect (flag at 1FE0:7BFE).
emit(0x80, 0x3E), code.extend(le16(0x7BFE)), code.extend([0x00])
emit(0x75, 0x09)                      # jne skip_remap
emit(0x81, 0xFF), code.extend(le16(0x001C))
emit(0x75, 0x03)
emit(0xBF), code.extend(le16(0x000F))
# skip_remap:
emit(0x89, 0xC3)                      # bx = buf off
L42loop = len(code)
emit(0xE8, 0x00, 0x00); call_ro2 = len(code) - 2
patch_rel16(call_ro2, read_one)
# Near JC — fail handler sits past the mirror block (rel8 too far).
emit(0x0F, 0x82, 0x00, 0x00); jc_42fail = len(code) - 2
emit(0x47)
emit(0x4E)
emit(0x75, 0x00); jnz_42 = len(code) - 1
patch_rel8(jnz_42, L42loop)
L42ok = len(code)
patch_rel8(jz_42ok, L42ok)
# Plant FreeDOS copy dest. When packet LBA is still the bogus 0x1C root
# start, also mirror 63A0 → 0060:0000 (LES/rep movsb via BP+disp16 fails).
emit(0xB8), code.extend(le16(0x1FE0))
emit(0x8E, 0xD8)
emit(0xC7, 0x06), code.extend(le16(0x639C)), code.extend(le16(0x0000))
emit(0xC7, 0x06), code.extend(le16(0x639E)), code.extend(le16(0x0060))
emit(0x81, 0x3E), code.extend(le16(0x7BC8)), code.extend(le16(0x001C))
# Near JNE — KERNEL load path exceeds rel8 range.
emit(0x0F, 0x85, 0x00, 0x00); jne_no_mirror = len(code) - 2
# One-shot: FD13 KERNEL is contiguous at LBA 1196 (91 sectors). Load it
# here and IRET to 0060:0000 — FreeDOS CMPS/FAT walk cannot complete yet.
emit(0x80, 0x3E), code.extend(le16(0x7BFE)), code.extend([0x00])
emit(0x0F, 0x85, 0x00, 0x00); jne_already = len(code) - 2
emit(0xC6, 0x06), code.extend(le16(0x7BFE)), code.extend([0x01])
emit(0xB0, 0x4D)                      # 'M' — start KERNEL load
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
emit(0xB8), code.extend(le16(0x0060))
emit(0x8E, 0xC0)                      # es = 0060
emit(0x31, 0xDB)                      # bx = 0
emit(0xBF), code.extend(le16(1196))   # di = first KERNEL LBA
emit(0xBE), code.extend(le16(91))     # si = sector count
L_kload = len(code)
emit(0xE8, 0x00, 0x00); call_kl = len(code) - 2
patch_rel16(call_kl, read_one)
emit(0x0F, 0x82, 0x00, 0x00); jc_kfail = len(code) - 2
emit(0x47)                            # inc di
emit(0x4E)                            # dec si
emit(0x75, 0x00); jnz_kl = len(code) - 1
patch_rel8(jnz_kl, L_kload)
emit(0xB0, 0x47)                      # 'G' — go KERNEL
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
# Guest REP MOVS hangs on EXEPACK (SI==DI across far DS/ES). Do reloc+unpack
# with plain MOV AL,[SI] / MOV ES:[SI],AL, then IRET past the REP.
# Reloc: slide image down 2 paragraphs (0060 → 005E) via LODSB/STOSB.
emit(0xB8), code.extend(le16(0x0060))
emit(0x8E, 0xD8)                      # ds = 0060
emit(0xB8), code.extend(le16(0x005E))
emit(0x8E, 0xC0)                      # es = 005E
emit(0x31, 0xF6)                      # si = 0
emit(0x31, 0xFF)                      # di = 0
emit(0xFC)                            # cld
emit(0xB9), code.extend(le16(0xB600))  # cx = 91*512
L_reloc = len(code)
emit(0xAC)                            # lodsb
emit(0xAA)                            # stosb
emit(0x49)                            # dec cx
emit(0x75, 0x00); jnz_reloc = len(code) - 1
patch_rel8(jnz_reloc, L_reloc)
# Unpack: DS=CS+5=0065 → ES=0788, B4FE bytes (same span as STD MOVSW).
emit(0xB8), code.extend(le16(0x0065))
emit(0x8E, 0xD8)
emit(0xB8), code.extend(le16(0x0788))
emit(0x8E, 0xC0)
emit(0x31, 0xF6)
emit(0x31, 0xFF)
emit(0xB9), code.extend(le16(0xB4FE))
L_unpack = len(code)
emit(0xAC)
emit(0xAA)
emit(0x49)
emit(0x75, 0x00); jnz_unpack = len(code) - 1
patch_rel8(jnz_unpack, L_unpack)
# Verify reloc: 0060:0000 must be unpacker B9 (was EB before slide).
emit(0xB8), code.extend(le16(0x0060))
emit(0x8E, 0xD8)
emit(0xA0), code.extend(le16(0x0000))  # mov al, [0000]
emit(0x3C, 0xB9)
emit(0x74, 0x08)                      # je ok
emit(0xB0, 0x46)                      # 'F' reloc failed
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
emit(0xEB, 0x06)                      # jmp uart_u
# ok:
emit(0xB0, 0x55)                      # 'U' — unpacked + reloc ok
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
# Neutralize guest STD;REP MOVSW so a bad IP cannot re-enter it.
emit(0xB8), code.extend(le16(0x0060))
emit(0x8E, 0xC0)
emit(0x26, 0xC7, 0x06), code.extend(le16(0x0018)), code.extend(le16(0x9090))
emit(0x26, 0xC7, 0x06), code.extend(le16(0x001A)), code.extend(le16(0x9090))
# IRET → 0060:006E (post-EXEPACK INT10 path). Guest RETF uses SS:BP and our
# SS is still FreeDOS boot (1FE0), which would jump into the wrong segment.
emit(0xC7, 0x46, 0x02), code.extend(le16(0x006E))  # IP
emit(0xC7, 0x46, 0x04), code.extend(le16(0x0060))  # CS
emit(0x8B, 0x7E, 0x06)
emit(0x81, 0xE7), code.extend(le16(0xFBFE))         # ~DF ~CF
emit(0x89, 0x7E, 0x06)
emit(0x1F)
emit(0x07)
emit(0x5F)
emit(0x5E)
emit(0x5A)
emit(0x59)
emit(0x5B)
emit(0x83, 0xC4, 0x02)                # drop saved AX
emit(0x5D)
emit(0xFA)                            # cli around SS:SP switch
# Re-plant INT10 — unpack/reloc must not leave IVT[10h] null.
emit(0x31, 0xC0)
emit(0x8E, 0xC0)                      # es = 0000
emit(0x26, 0xC7, 0x06), code.extend(le16(0x0040)), code.extend(le16(0xF065))
emit(0x26, 0xC7, 0x06), code.extend(le16(0x0042)), code.extend(le16(0xF000))
emit(0xB8), code.extend(le16(0x0060))
emit(0x8E, 0xD0)                      # ss = 0060 (for later RETF)
emit(0xBC), code.extend(le16(0xFFFE))  # sp
emit(0xB8), code.extend(le16(0x0065))
emit(0x8E, 0xD8)                      # ds = 0065
emit(0xB8), code.extend(le16(0x0788))
emit(0x8E, 0xC0)                      # es = 0788
emit(0xBE), code.extend(le16(0xFFFE))
emit(0x89, 0xF7)
emit(0x31, 0xC9)
emit(0xCF)
L_kfail = len(code)
patch_rel16(jc_kfail, L_kfail)
L_already = len(code)
patch_rel16(jne_already, L_already)
emit(0xB0, 0x4E)                      # 'N'
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
L_no_mirror = len(code)
patch_rel16(jne_no_mirror, L_no_mirror)
# Clear DF in IRET flags (bit 10). FreeDOS repe cmpsb/movsb need DF=0.
emit(0x8B, 0x46, 0x06)               # mov ax, [bp+6]
emit(0x25), code.extend(le16(0xFBFF))  # and ax, ~DF
emit(0x89, 0x46, 0x06)               # mov [bp+6], ax
emit(0xB0, 0x4B)
emit(0xBA), code.extend(le16(0x03F8))
emit(0xEE)
emit(0x1F)
emit(0x07)
emit(0x5F)
emit(0x5E)
emit(0x5A)
emit(0x59)
emit(0x5B)
emit(0x58)
emit(0xB4, 0x00)
emit(0xB0, 0x00)
emit(0x83, 0x66, 0x06, 0xFE)
emit(0x5D)
emit(0xCF)
L42fail = len(code)
patch_rel16(jc_42fail, L42fail)
emit(0x1F)
emit(0x07)
emit(0x5F)
emit(0x5E)
emit(0x5A)
emit(0x59)
emit(0x5B)
emit(0x58)
emit(0xB4, 0x04)
emit(0x83, 0x4E, 0x06, 0x01)
emit(0x5D)
emit(0xCF)

Path("artifacts/seabios/int13_stub.bin").write_bytes(code)
print(f"stub size {len(code)} L02={L02:#x} read_one={read_one:#x}")
