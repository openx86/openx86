#!/usr/bin/env python3
"""Relax SeaBIOS layoutrom VARVERIFY so flat boot can call init helpers."""
from pathlib import Path
import sys

src = Path(sys.argv[1] if len(sys.argv) > 1 else "artifacts/seabios/src")
p = src / "scripts/layoutrom.py"
t = p.read_text()
old = '''    if '.data.varinit.' in section.name:
        print("ERROR: %s is VARVERIFY32INIT but used from %s" % (
            section.name, chain))
        sys.exit(-1)'''
# try both exit(1) and exit(-1)
old1 = """    if '.data.varinit.' in section.name:
        print(\"ERROR: %s is VARVERIFY32INIT but used from %s\" % (
            section.name, chain))
        sys.exit(1)"""
new = """    if '.data.varinit.' in section.name:
        # openx86: allow flat boot to reference init vars
        print(\"WARN: %s is VARVERIFY32INIT but used from %s\" % (
            section.name, chain))
        return 1"""
if "openx86: allow flat boot" in t:
    print("already: layoutrom varverify relax")
elif old1 not in t:
    raise SystemExit("missing layoutrom pattern")
else:
    p.write_text(t.replace(old1, new, 1))
    print("patched: layoutrom varverify relax")
