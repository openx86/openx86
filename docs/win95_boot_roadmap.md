# OpenX86 — 80486DX ISA + Windows 95 Desktop Roadmap

Acceptance environment: **Verilator + full SoC** (`openx86_soc_top`).
Architectural target: **Intel 80486DX** (CPUID family=4, on-chip FPU).
Win95 disk/BIOS images are **not** committed; load via `+SEABIOS_BIN=` / `+DISK_IMG=`.

## Policy

1. Unimplemented opcodes raise **#UD** (never silent NOP).
2. Post-486 features (MMX/SSE/MSR/…) stay out of CPUID; decode may #UD.
3. Each milestone has regression TB; CI covers through SeaBIOS smoke where legal artifacts exist.

## Milestone checklist

### M0 — ISA contract

- [x] `docs/win95_boot_roadmap.md`
- [x] CPUID identity = 486DX (family 4) + EAX/EBX/ECX/EDX writeback
- [x] Unmapped `dec_to_uop` → `MISC_SUB_UD`
- [x] Fix CWDE/CDQ/CWD decode bugs
- [x] Instruction footprint TB scaffold (`tb/cpu/isa/instruction_footprint_tb.sv`)

### M1 — User integer ISA

- [x] ENTER subcode reserved (`MISC_SUB_ENTER`; full decode port chain TBD)
- [x] LEAVE micro-op + EXU skeleton (ESP:=EBP + POP EBP)
- [x] PUSH/POP segment register mapping
- [x] CBW / CWDE / CDQ / XLAT / BCD subcodes + EXU
- [x] REP/REPE/REPNE string unit restart interface (prefix→uop wiring ongoing)
- [x] BOUND / ARPL subcodes
- [x] FLAG_CTRL immediates for CLC/STC/CMC/CLD/STD/CLI/STI

### M2 — Protected mode / paging

- [x] Simple TLB (`rtl/cpu/mmu/paging/tlb_simple.sv`) + INVLPG invalidate path
- [x] Wire TLB into `paging_unit` (fill on walk, hit bypass, invall/invlpg ports)
- [x] System instruction MISC subcodes (LAR/LSL/VERR/VERW/LLDT/LTR/CLTS/SMSW/LEAVE/…)
- [x] EXU stubs: CLTS (clear CR0.TS), SMSW (read CR0[15:0]), LEAVE (ESP=EBP + POP skeleton)
- [ ] Full descriptor privilege checks (ongoing)
- [ ] Complete far JMP/CALL/RET privilege rules (ongoing)

### M3 — Interrupt / TSS

- [x] TSS privilege stack helper (`rtl/cpu/mmu/tss/tss_privilege_stack.sv`)
- [x] IDU optional stack-switch inputs (`i_need_stack_switch`, `i_new_ss`, `i_new_esp`, …)
- [ ] Full task gate / task switch (ongoing)
- [ ] Nested task NT / busy TSS (ongoing)
- [ ] Wire TSS helper + old SS cache into EIU parent (pending)

### M4 — Virtual 8086

- [x] `rtl/cpu/v86/v86_sensitive_check.sv` (CLI/STI/PUSHF/POPF/INT/IRET/IN/OUT vs IOPL)
- [x] Instantiate checker in `i486_cpu_pipeline` (opcode class bits stubbed 0)
- [ ] Full V86 monitor exception restart (ongoing)
- [ ] I/O permission bitmap walk (ongoing)

### M5 — x87 (486DX)

- [x] `x87_cr0_gate` (#NM when CR0.EM|TS)
- [x] FLDCW / FSTCW / FSTSW / FINIT subops in `x87_fpu_core`
- [ ] Wire `x87_cr0_gate` into EXU/#NM delivery (pending)
- [ ] FLDENV/FSTENV/full compare/transcendentals (ongoing)
- [ ] Wait/#MF precise delivery (ongoing)

### M6 — Chipset / disk / display

- [x] IDE/SoC TB disk image `$fread` preload path (`g_bram_only.image`)
- [x] 8237 DMA CH2 master transfer engine documented
- [ ] Full SeaBIOS port probe compatibility (ongoing)

### M7 — SeaBIOS POST

- [x] `tb/seabios_post_tb.sv` checkpoint framework (UART “SeaBIOS” → CP1)
- [ ] INT13 disk chain-load golden (needs local SeaBIOS binary)

### M8 — Windows 95 desktop

- [x] `tb/win95_boot_tb.sv` CP0–CP6 checkpoint framework
- [ ] CP2–CP6 pass against real Win95 image (local / private runner)

## Boot checkpoints (Win95 TB)

| CP | Meaning |
|----|---------|
| CP0 | Reset / BIOS entry |
| CP1 | SeaBIOS POST complete (UART/log) |
| CP2 | MBR → IO.SYS / bootloader |
| CP3 | Protected mode / paging enabled |
| CP4 | V86 / driver init stable |
| CP5 | Graphics mode switch |
| CP6 | Desktop framebuffer signature |

## Hierarchical TB paths

| Resource | Path |
|----------|------|
| BIOS EEPROM | `dut.u_bios_24lc32.mem` |
| IDE disk BRAM | `dut.u_bus_controller.u_ide.u_disk.g_bram_only.image` |
| COM1 TX byte | `dut.u_bus_controller.u_chip_com1.thr_shadow` |
| COM1 TX strobe | `dut.u_bus_controller.u_chip_com1.thr_write_pulse` |

## Local run examples

```bash
# Smoke (no guest images)
scripts/sim_tb_verilator.sh --tb tb/win95_boot_tb.sv

# SeaBIOS POST (provide your binary)
scripts/sim_tb_verilator.sh --tb tb/seabios_post_tb.sv \
  +SEABIOS_BIN=/path/to/bios.bin +MAX_CYCLES=5000000

# Win95 ladder (legal local image)
scripts/sim_tb_verilator.sh --tb tb/win95_boot_tb.sv \
  +SEABIOS_BIN=/path/to/bios.bin +DISK_IMG=/path/to/win95.img \
  +MAX_CYCLES=200000000
```
