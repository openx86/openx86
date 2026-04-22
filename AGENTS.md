# OpenX86 — Agent Rules (compact)

**Scope:** `rtl/**/*.sv` synthesizable SV; `tb/**/*.sv` TBs.

**File header (required top of every `*.sv`):** MIT license format with copyright notice, permission text, file metadata, and description:

```systemverilog
// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : <filename>.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : <concise module description>
// ============================================================================
```

**Ports:** all `logic`; `i_`/`o_`/`b_`; PHY: `{dir}_{module}_phy_{name}`; last ports always `clk`, `rst_n` (exact names); bus widths `[31: 0]` style (spaces around `:`); align columns (dir, logic, width, name); one port/connection per line; align `.(...)`.

**Internals:** `logic` only (no `wire`/`reg`); FSM `typedef enum logic [...]`; same-name continuous drive → single `logic x = expr;` (no split `assign`).

**Alignment:**

- Port declarations: align columns (direction, logic, width, name) with consistent indentation
- Bus widths: use `[31: 0]` style with spaces around the colon
- Assignment statements: align `=` and `<=` operators vertically for related assignments
- Module instantiation: align `.(...)` port connections vertically
- Maintain consistent spacing and indentation throughout the file

**RTL synthesizability:** no `initial` for behavior (ROM init wrappers exception with review); no `#`/`##`/fork timing in synth logic; no `force`/`assign-deassign`/DPI; `always_ff` + `<=`; `always_comb` + `=`; defaults + full branches; no ad-hoc gated clocks; clock-enable preferred.

**Reset/clock:** active-low `rst_n`; `always_ff @(posedge clk or negedge rst_n)`; reset defines full arch state; avoid reset on pure datapath unless needed + documented.

**Files:** one main module per `rtl/*.sv` (wrapper exceptions with review); filename ≈ module; shared defs → `rtl/common/` or `@include/`; explicit includes/packages.

**Bus vs peripheral:** `rtl/device/` = CPU-bus controllers; new bus-visible logic → controller + decode in bus integration; `rtl/peripheral/` = PHY/protocol only, never CPU-bus direct; only `rtl/bus_controller.sv` (or designated top) maps devices to CPU address space.

**Naming:** params `P_*`, localparams `LP_*`, FSM type `<n>_state_t`, regs `<n>_state` / `<n>_state_n`, active-low `*_n`.

**Numeric:** sized literals (`8'h00`, `1'b0`); explicit signedness when needed; width-safe ops.

**CDC:** approved sync; 1-bit ≥2 flops; multi-bit handshake/FIFO/gray; no deep combo on async inputs.

**TB:** under `tb/`; path/name mirrors `rtl/` + `_tb.sv` suffix; each RTL module should have a TB; non-synth constructs only in `tb/`. Testbench file naming must be `{module_name}_tb.sv` where `module_name` exactly matches the RTL module name. The directory structure in `tb/` must mirror the directory structure in `rtl/` exactly.

**Quality:** lint + TB regressions + no meaningful new synth warnings; assertions for invariants; deterministic TB reset/startup.

**Shell scripts (`*.sh`):** Unix line endings only (LF), not Windows CRLF. Normalize before commit so scripts run correctly on Linux/macOS and in CI.

**Language policy (`*.sv`/`*.sh`):** Chinese is allowed in comments only; all non-comment content (identifiers, string literals/messages, directives, shell commands, paths) must be English. Add concise Chinese comments only where they improve readability of non-trivial logic, and keep runtime prompts/messages in English.

**Review (quick):** header; port prefixes/PHY/last `clk`/`rst_n`; width/spacing/alignment; synth RTL; device vs peripheral layering; TB 1:1 map; CDC/reset/FSM style.
