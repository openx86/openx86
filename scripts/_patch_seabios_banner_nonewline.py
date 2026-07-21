#!/usr/bin/env python3
from pathlib import Path
import sys
p = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src") / "src/output.c"
t = p.read_text()
old = 'dprintf(1, "SeaBIOS\\n");'
new = 'dprintf(1, "SeaBIOS"); /* openx86: no newline */'
if "no newline" in t:
    print("already")
elif old not in t:
    raise SystemExit("missing banner dprintf")
else:
    p.write_text(t.replace(old, new, 1))
    print("patched no newline")
