# OpenX86 RTL and Verification Rules

## Scope
- These rules apply to all RTL files under `rtl/**/*.sv`.
- These rules apply to all testbench files under `tb/**/*.sv`.
- Files under `rtl/` MUST be synthesizable SystemVerilog.

## File Header Comment Rules
- Every `*.sv` file MUST start with the following header comment block at the top of the file.
- `description` MUST be filled with a concise module/function description.

Template:

```systemverilog
/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: {desc_text}
*/
```

## 1) Port List Rules
- All module ports MUST use `logic` type.
- Direction prefixes are mandatory:
  - `input`  -> `i_`
  - `output` -> `o_`
  - `inout`  -> `b_`
- Physical-layer ports MUST include `phy` and follow this format:
  - `{dir_prefix}_{module_name}_phy_{port_name}`
  - Examples: `i_sdcard_phy_dat`, `o_sdcard_phy_cmd`, `b_uart_phy_rx`.
- `clock` and `reset_n` MUST be the last ports in the list.
  - Project exception: keep these two names as `clock` and `reset_n`.
- Port width style MUST include alignment spaces:
  - Use `[31: 0]`, `[ 3: 0]`, `[ 0: 0]`
  - Do NOT use `[31:0]`, `[3:0]`
- Port declarations MUST be vertically aligned by columns:
  - direction, `logic`, width, name.

Reference style:

```systemverilog
module example_module (
    input  logic         i_example_req,
    input  logic [31: 0] i_example_addr,
    output logic [ 7: 0] o_example_data,
    inout  logic         b_example_gpio,
    input  logic         clock,
    input  logic         reset_n
);
```

## 2) Signal Type Rules
- Use `logic` for all internal signals.
- Do NOT use `wire` or `reg` in project RTL/TB coding style.
- Use `typedef enum logic [...]` for FSM states.

## 3) Synthesizability Rules for rtl/**/*.sv
- RTL under `rtl/` MUST be synthesizable.
- Prohibited in `rtl/`:
  - `initial` blocks for design behavior (except vendor-safe ROM init wrappers with review).
  - Delay controls such as `#`, `##`, `wait fork`, `fork...join_any` for synthesizable logic.
  - `force/release`, `assign/deassign`, DPI calls.
- Sequential logic MUST use `always_ff` with non-blocking assignments (`<=`).
- Combinational logic MUST use `always_comb` with blocking assignments (`=`).
- Avoid inferred latches:
  - Give default assignments in combinational processes.
  - Cover all branches in `if/case` logic.
- Use synchronous design practices:
  - No gated/generated local clocks for functional logic unless explicitly reviewed.
  - Use clock-enable style when possible.

## 4) Reset and Clocking Rules
- Default reset policy is active-low reset: `reset_n`.
- Async reset template (preferred existing style):
  - `always_ff @(posedge clock or negedge reset_n)`
- Reset values MUST fully define architectural state.
- Avoid reset on pure datapath pipelines unless functionally required and documented.

## 5) Module and File Organization
- One synthesizable module per `rtl/*.sv` file (wrapper exceptions allowed with review).
- File name SHOULD match the main module name.
- Shared constants/types SHOULD be placed under `rtl/common/` or `@include/`.
- Use explicit package/include dependencies; avoid hidden compile order coupling.

## Device/Peripheral Integration Rules
- Modules under `rtl/device/` MUST be controllers that can be attached to the X86 CPU bus (directly or through `bus_controller`).
- New bus-visible functionality MUST be added in `rtl/device/` as a controller, with clear bus-side interface and address decode integration.
- Modules under `rtl/peripheral/` are external/peripheral logic only (PHY/protocol/device-side), and MUST NOT be directly mapped onto the X86 CPU bus.
- Every peripheral in `rtl/peripheral/` MUST be accessed through a controller in `rtl/device/` before reaching the CPU bus.
- `rtl/bus_controller.sv` (or the designated top-level bus integration module) is the only place to expose device controllers to the CPU bus address space.

## 6) Naming and Style Conventions
- Parameters: `P_*`
- Localparams: `LP_*`
- FSM state types: `<name>_state_t`
- FSM state regs: `<name>_state`, `<name>_state_n`
- Active-low signals end with `_n`.
- Keep comments concise and intent-focused; explain protocol timing and corner cases.

## 7) Numeric and Expression Rules
- Prefer sized literals: `8'h00`, `1'b0`, `32'd0`.
- Avoid unsized decimal literals in arithmetic datapaths.
- Match signedness explicitly using `logic signed` or casts when needed.
- Use width-safe concatenation/slicing and avoid accidental truncation.

## 8) CDC and Interface Safety
- Any clock-domain crossing MUST use approved synchronizer patterns.
- Single-bit CDC: 2-flop synchronizer minimum.
- Multi-bit CDC: handshake/FIFO/gray-code scheme.
- Do not sample async external inputs directly into deep logic.

## 9) Testbench Mapping Rules
- Testbench files MUST be placed under `tb/`.
- `tb/` hierarchy and filenames MUST map 1:1 to `rtl/` modules.
  - Example mapping:
    - RTL: `rtl/peripheral/sd/sd_native_host_4bit.sv`
    - TB:  `tb/peripheral/sd/sd_native_host_4bit_tb.sv`
- Each synthesizable RTL module SHOULD have at least one dedicated testbench.
- Testbench code may use non-synthesizable constructs, but only under `tb/`.

## 10) Verification and Quality Gates
- New/modified RTL MUST pass:
  - Lint checks (Verilator/other configured linters).
  - Relevant testbench regressions.
  - No new synthesis warnings of functional significance.
- Prefer assertions for protocol/state invariants.
- Use deterministic reset/startup sequencing in all TBs.

## 11) Review Checklist
- [ ] Every `*.sv` starts with the standard project header comment block.
- [ ] Ports follow direction prefixes (`i_`, `o_`, `b_`).
- [ ] PHY ports follow `{dir}_{module}_phy_{name}`.
- [ ] `clock` and `reset_n` are the final ports.
- [ ] Width formatting is `[31: 0]` style with aligned columns.
- [ ] All ports/signals use `logic`.
- [ ] `rtl/**/*.sv` content is synthesizable.
- [ ] New CPU-bus-visible modules are implemented as controllers under `rtl/device/`.
- [ ] `rtl/peripheral/` modules are connected through `rtl/device/` controllers, not directly CPU-bus mapped.
- [ ] `tb/` path and testbench name match RTL module 1:1.
- [ ] CDC/reset/FSM style follows project rules.
