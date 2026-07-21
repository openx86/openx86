#!/usr/bin/env python3
b = open("artifacts/freedos/disk.img", "rb").read()[:512]
ea, end = 0x15E, 0x1F0


def u16(x):
    return b[x] | b[x + 1] << 8


def s8(x):
    v = b[x]
    return v - 256 if v > 127 else v


def s16(x):
    v = u16(x)
    return v - 65536 if v > 32767 else v


i = ea
while i < end:
    op = b[i]
    o = f"{0x7C00 + i:04X}  "
    if op == 0x56:
        print(o + "push si")
        i += 1
        continue
    if op == 0x57:
        print(o + "push di")
        i += 1
        continue
    if op == 0x5E:
        print(o + "pop si")
        i += 1
        continue
    if op == 0x5F:
        print(o + "pop di")
        i += 1
        continue
    if op == 0x50:
        print(o + "push ax")
        i += 1
        continue
    if op == 0x58:
        print(o + "pop ax")
        i += 1
        continue
    if op == 0x1E:
        print(o + "push ds")
        i += 1
        continue
    if op == 0x07:
        print(o + "pop es")
        i += 1
        continue
    if op == 0xC3:
        print(o + "ret")
        i += 1
        continue
    if op == 0xCD:
        print(o + f"int {b[i+1]:02X}")
        i += 2
        continue
    if op == 0xB4:
        print(o + f"mov ah,{b[i+1]:02X}")
        i += 2
        continue
    if op == 0xB8:
        print(o + f"mov ax,{u16(i+1):04X}")
        i += 3
        continue
    if op == 0xB9:
        print(o + f"mov cx,{u16(i+1):04X}")
        i += 3
        continue
    if op == 0xBB:
        print(o + f"mov bx,{u16(i+1):04X}")
        i += 3
        continue
    if op == 0xBE:
        print(o + f"mov si,{u16(i+1):04X}")
        i += 3
        continue
    if op == 0xE8:
        t = i + 3 + s16(i + 1)
        print(o + f"call {0x7C00 + t:04X}")
        i += 3
        continue
    if op == 0xEB:
        t = i + 2 + s8(i + 1)
        print(o + f"jmp short {0x7C00 + t:04X}")
        i += 2
        continue
    if op == 0x74:
        t = i + 2 + s8(i + 1)
        print(o + f"jz {0x7C00 + t:04X}")
        i += 2
        continue
    if op == 0x75:
        t = i + 2 + s8(i + 1)
        print(o + f"jnz {0x7C00 + t:04X}")
        i += 2
        continue
    if op == 0x72:
        t = i + 2 + s8(i + 1)
        print(o + f"jb {0x7C00 + t:04X}")
        i += 2
        continue
    if op == 0x8A and b[i + 1] == 0x56:
        print(o + f"mov dl,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0x8A and b[i + 1] == 0x46:
        print(o + f"mov al,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0x8B and b[i + 1] == 0x46:
        print(o + f"mov ax,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0x8B and b[i + 1] == 0x4E:
        print(o + f"mov cx,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0x8B and b[i + 1] == 0x56:
        print(o + f"mov dx,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0x89 and b[i + 1] == 0x46:
        print(o + f"mov [bp+{b[i+2]:02X}],ax")
        i += 3
        continue
    if op == 0x89 and b[i + 1] == 0x56:
        print(o + f"mov [bp+{b[i+2]:02X}],dx")
        i += 3
        continue
    if op == 0x89 and b[i + 1] == 0x5E:
        print(o + f"mov [bp+{b[i+2]:02X}],bx")
        i += 3
        continue
    if op == 0x84 and b[i + 1] == 0xD2:
        print(o + "test dl,dl")
        i += 2
        continue
    if op == 0xD1 and b[i + 1] == 0xE8:
        print(o + "shr ax,1")
        i += 2
        continue
    if op == 0xD1 and b[i + 1] == 0xE9:
        print(o + "shr cx,1")
        i += 2
        continue
    if op == 0x81 and b[i + 1] == 0xDB:
        print(o + f"sbb bx,{u16(i+2):04X}")
        i += 4
        continue
    if op == 0x8D and b[i + 1] == 0x76:
        d = b[i + 2]
        ds = d - 256 if d > 127 else d
        print(o + f"lea si,[bp{ds:+d}]")
        i += 3
        continue
    if op == 0x8C and b[i + 1] == 0x86:
        print(o + f"mov [bp+{u16(i+2):04X}],es")
        i += 4
        continue
    if op == 0x89 and b[i + 1] == 0x9E:
        print(o + f"mov [bp+{u16(i+2):04X}],bx")
        i += 4
        continue
    if op == 0xC4 and b[i + 1] == 0x5E:
        print(o + f"les bx,[bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0xC4 and b[i + 1] == 0xBE:
        print(o + f"les di,[bp+{u16(i+2):04X}]")
        i += 4
        continue
    if op == 0xF3 and b[i + 1] == 0xA4:
        print(o + "rep movsb")
        i += 2
        continue
    if op == 0x83 and b[i + 1] == 0x46:
        print(o + f"add word [bp+{b[i+2]:02X}],{b[i+3]}")
        i += 4
        continue
    if op == 0x83 and b[i + 1] == 0x56:
        print(o + f"adc word [bp+{b[i+2]:02X}],{b[i+3]}")
        i += 4
        continue
    if op == 0x4F:
        print(o + "dec di")
        i += 1
        continue
    if op == 0x41:
        print(o + "inc cx")
        i += 1
        continue
    if op == 0x2E:
        print(o + "cs:")
        i += 1
        continue
    if op == 0xF6 and b[i + 1] == 0x66:
        print(o + f"mul byte? [bp+{b[i+2]:02X}]")
        i += 3
        continue
    if op == 0xF7 and b[i + 1] == 0xF1:
        print(o + "div cx")
        i += 2
        continue
    if op == 0x91:
        print(o + "xchg ax,cx")
        i += 1
        continue
    if op == 0x92:
        print(o + "xchg ax,dx")
        i += 1
        continue
    if op == 0x86 and b[i + 1] == 0xE9:
        print(o + "xchg cl,ch")
        i += 2
        continue
    if op == 0x88 and b[i + 1] == 0xC6:
        print(o + "mov dh,al")
        i += 2
        continue
    if op == 0xD0 and b[i + 1] == 0xC9:
        print(o + "ror cl,1")
        i += 2
        continue
    if op == 0x08 and b[i + 1] == 0xE1:
        print(o + "or cl,ah")
        i += 2
        continue
    if op == 0x01 and b[i + 1] == 0x86:
        print(o + f"add [bp+{u16(i+2):04X}],ax")
        i += 4
        continue
    if op == 0xB1:
        print(o + f"mov cl,{b[i+1]:02X}")
        i += 2
        continue
    if op == 0xD3 and b[i + 1] == 0xE8:
        print(o + "shr ax,cl")
        i += 2
        continue
    print(o + f"db {op:02X}")
    i += 1
