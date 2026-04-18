# OpenX86 — Agent Rules (compact)

**Scope:** `rtl/**/*.sv` synthesizable SV; `tb/**/*.sv` TBs.

**File header (required top of every `*.sv`):** `project: openx86`, `author: Chang Wei<changwei1006@gmail.com>`, `repo: https://github.com/openx86/openx86`, `description: <concise>`.

**Ports:** all `logic`; `i_`/`o_`/`b_`; PHY: `{dir}_{module}_phy_{name}`; last ports always `clock`, `reset_n` (exact names); bus widths `[31: 0]` style (spaces around `:`); align columns (dir, logic, width, name); one port/connection per line; align `.(...)`.

**Internals:** `logic` only (no `wire`/`reg`); FSM `typedef enum logic [...]`; same-name continuous drive → single `logic x = expr;` (no split `assign`).

**RTL synthesizability:** no `initial` for behavior (ROM init wrappers exception with review); no `#`/`##`/fork timing in synth logic; no `force`/`assign-deassign`/DPI; `always_ff` + `<=`; `always_comb` + `=`; defaults + full branches; no ad-hoc gated clocks; clock-enable preferred.

**Reset/clock:** active-low `reset_n`; `always_ff @(posedge clock or negedge reset_n)`; reset defines full arch state; avoid reset on pure datapath unless needed + documented.

**Files:** one main module per `rtl/*.sv` (wrapper exceptions with review); filename ≈ module; shared defs → `rtl/common/` or `@include/`; explicit includes/packages.

**Bus vs peripheral:** `rtl/device/` = CPU-bus controllers; new bus-visible logic → controller + decode in bus integration; `rtl/peripheral/` = PHY/protocol only, never CPU-bus direct; only `rtl/bus_controller.sv` (or designated top) maps devices to CPU address space.

**Naming:** params `P_*`, localparams `LP_*`, FSM type `<n>_state_t`, regs `<n>_state` / `<n>_state_n`, active-low `*_n`.

**Numeric:** sized literals (`8'h00`, `1'b0`); explicit signedness when needed; width-safe ops.

**CDC:** approved sync; 1-bit ≥2 flops; multi-bit handshake/FIFO/gray; no deep combo on async inputs.

**TB:** under `tb/`; path/name mirrors `rtl/` + `_tb.sv` suffix; each RTL module should have a TB; non-synth constructs only in `tb/`.

**Quality:** lint + TB regressions + no meaningful new synth warnings; assertions for invariants; deterministic TB reset/startup.

**Review (quick):** header; port prefixes/PHY/last `clock`/`reset_n`; width/spacing/alignment; synth RTL; device vs peripheral layering; TB 1:1 map; CDC/reset/FSM style.
