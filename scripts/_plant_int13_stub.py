from pathlib import Path
import re

stub = Path("artifacts/seabios/int13_stub.bin").read_bytes()
stub_c = ",\n            ".join(
    ", ".join(f"0x{b:02x}" for b in stub[i : i + 12])
    for i in range(0, len(stub), 12)
)

def make_block(asm_escape: str) -> str:
    # asm_escape: "\\n" for live C file, "\\\\n" for python patch string
    return f"""    serial_debug_putc('J');
    /*
     * Plant 16-bit INT13 ATA stub at 0000:9000 (skip SeaBIOS 16->32 transition),
     * restore IVT INT10/16; far-jump to FreeDOS 1FE0:7C5E.
     */
    {{
        static u8 stub[] = {{
            {stub_c}
        }};
        u8 *dst = (u8 *)0x9000;
        u32 i;
        for (i = 0; i < sizeof(stub); i++)
            dst[i] = stub[i];
        static volatile u8 rmidt[8] = {{
            0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa
        }};
        u32 v13 = 0x00009000, v10 = 0xF000F065, v16 = 0xF000E82E;
        asm volatile("movl %0, 0x4c" : : "r"(v13) : "memory");
        asm volatile("movl %0, 0x40" : : "r"(v10) : "memory");
        asm volatile("movl %0, 0x58" : : "r"(v16) : "memory");
        asm volatile(
            "invd{asm_escape}"
            "lidtl %0{asm_escape}"
            "movb $0x80, %%dl{asm_escape}"
            "movl %%cr0, %%eax{asm_escape}"
            "andl $~1, %%eax{asm_escape}"
            "movl %%eax, %%cr0{asm_escape}"
            "movw $0x1FE0, %%ax{asm_escape}"
            "movw $0x7C00, %%bp{asm_escape}"
            ".byte 0x66, 0xea, 0x5e, 0x7c, 0xe0, 0x1f{asm_escape}"
            :
            : "m"(rmidt[0])
            : "eax", "edx", "cc", "memory");
    }}
    return;"""

post = Path("artifacts/seabios/src/src/post.c")
t = post.read_text()
m = re.search(
    r"    serial_debug_putc\('J'\);\n    /\*.*?\*/\n    \{.*?\n    \}\n    return;",
    t,
    re.S,
)
if not m:
    raise SystemExit("block not found in post.c")
post.write_text(t[: m.start()] + make_block("\\n") + t[m.end() :])
print("updated post.c")

ps_path = Path("scripts/_patch_seabios_good.py")
ps = ps_path.read_text()
idx = ps.find("0x27A54")
if idx < 0:
    raise SystemExit("27A54 not in patch")
sub = ps[idx:]
m2 = re.search(r"    serial_debug_putc\('J'\);.*?    return;", sub, re.S)
if not m2:
    raise SystemExit("J block not in patch")
ps_path.write_text(ps[:idx] + sub[: m2.start()] + make_block("\\\\n") + sub[m2.end() :])
print("updated patch script")
