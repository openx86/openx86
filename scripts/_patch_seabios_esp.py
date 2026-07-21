#!/usr/bin/env python3
from pathlib import Path
import sys

p = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src") / "src/post.c"
t = p.read_text()
# Fix broken asm or insert correct one
import re
t2, n = re.subn(
    r'asm volatile\("movl \\?\$0x0008ff00, %%esp" ::: "esp"\);',
    'asm volatile("movl $0x0008ff00, %%esp" ::: "esp");',
    t,
)
if n == 0:
    # insert after early cli if missing
    needle = "    irq_disable(); /* openx86: early cli */\n"
    insert = needle + '    asm volatile("movl $0x0008ff00, %%esp" ::: "esp");\n'
    if '0x0008ff00' not in t and needle in t:
        t2 = t.replace(needle, insert, 1)
        n = 1
        print("inserted esp raise")
    else:
        print("no change needed or pattern missing")
        print([line for line in t.splitlines() if "esp" in line or "8ff00" in line][:5])
        sys.exit(0 if "movl $0x0008ff00" in t else 1)
else:
    print("fixed esp asm, count", n)
p.write_text(t2)
for i, l in enumerate(p.read_text().splitlines(), 1):
    if "8ff00" in l:
        print(i, l)
