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
- [x] Wire TSS helper + old SS cache into EIU parent (CPL≠0 → ESP0/SS0 fetch)
- [ ] Full task gate / task switch (ongoing)
- [ ] Nested task NT / busy TSS (ongoing)
- [ ] LTR loads real TR base/descriptor (soft `tr_base` placeholder)

### M4 — Virtual 8086

- [x] `rtl/cpu/v86/v86_sensitive_check.sv` (CLI/STI/PUSHF/POPF/INT/IRET/IN/OUT vs IOPL)
- [x] Instantiate checker in `i486_cpu_pipeline` (CLI/STI/PUSHF/POPF/INT/IRET/IN/OUT from uop)
- [ ] Full V86 monitor exception restart (ongoing)
- [ ] I/O permission bitmap walk (ongoing)

### M5 — x87 (486DX)

- [x] `x87_cr0_gate` (#NM when CR0.EM|TS)
- [x] FLDCW / FSTCW / FSTSW / FINIT subops in `x87_fpu_core`
- [x] Wire `x87_cr0_gate` into EXU/#NM delivery (vector 7)
- [ ] FLDENV/FSTENV/full compare/transcendentals (ongoing)
- [ ] Wait/#MF precise delivery (ongoing)

### M6 — Chipset / disk / display

- [x] IDE/SoC TB disk image `$fread` preload path (`g_bram_only.image`)
- [x] BIOS ROM 128KiB linear map (`E0000–FFFFF` / high alias) + PC reset `CS=F000 EIP=FFF0`
- [x] IDE BRAM ≥1.44MiB (2880 sectors); VGA text window CPU read path
- [x] 8237 DMA CH2 master transfer engine documented
- [x] Behavioral SDRAM byte/halfword merge (BE + RMW) + string step by width
- [x] Cache fill ready gated by completed beat PA (`o_req_ready_addr`); burst ADS/BRDY arm
- [ ] Full SeaBIOS port probe compatibility (ongoing)

### M7 — SeaBIOS POST + FreeDOS DIR

- [x] `tb/seabios_post_tb.sv` + `REQUIRE_POST=1` (UART “SeaBIOS”)
- [x] `tb/dos_boot_tb.sv` CP1–CP4 + `REQUIRE_DOS=1` (real `bios.bin` + FreeDOS; no TB VGA/IVT plant)
- [x] Scripts: `fetch_build_seabios.sh` → `_patch_seabios_good.py` (incl. skip THRE poll), `fetch_freedos_img.sh`
- [x] IDE data port 16-bit PIO; `CONFIG_ATA_PIO32=n`
- [x] Real-mode IVT INT (`IDTR` reset limit `3FFh`) + CS reload on delivery
- [x] BIU: IO IN/OUT keep payload in low bytes (no mem-style lane steer by port[1:0]) — fixes IDE `1F7` IDENTIFY
- [x] `REQUIRE_DOS=1` CP2: UART `Booting` + guest ATA READ LBA0 → `0000:7C00` (crumb `J`); no TB plant
- [ ] CP3/CP4: FreeDOS FD13 boot uses INT13 AH=41/42 then CHS; direct ATA INT13 stub added (`handle_13`) but KERNEL still not verified at `0060:0000` (mem@600 often 0). Need working `insw_fl` + packet parse + INT10 text. IRQ0/`handle_08` reboots — TB soft-ticks BDA `0x46C`. VGA halfword BE→two-byte write in `bus_controller`.
- [ ] `call16_int(0x19)` path still fragile; `startBoot` uses direct LBA0 + real-mode far jump

### FreeDOS ladder status (2026-07-21)

| CP | `REQUIRE_DOS=1` | Notes |
|----|-----------------|-------|
| CP1 | PASS | UART `SeaBIOS` |
| CP2 | PASS | `…OPDEQTBooting…J`, then guest at `CS=0060` |
| CP3 | FAIL | No guest prompt / no INT10 echo yet |
| CP4 | FAIL | DIR not reached |

`seabios_post REQUIRE_POST=1`: PASS (~2k cycles).

Live SeaBIOS tree under `artifacts/seabios/src` has more patches than `_patch_seabios_good.py` alone (INT10 stub, INT13 ATA PIO, map_hd minimal, debug_enter/isr stubs, skip e820 in bda_init). Rebuild in-tree; do not `checkout -f` without re-applying.

### Known-good SeaBIOS rebuild

```bash
git -C artifacts/seabios/src checkout -f -- src/
python3 scripts/_patch_seabios_good.py artifacts/seabios/src
# or: ./scripts/fetch_build_seabios.sh
make -C artifacts/seabios/src PYTHON=python3 olddefconfig && make -j"$(nproc)"
cp artifacts/seabios/src/out/bios.bin artifacts/seabios/bios.bin
```

WSL CI gate: `./scripts/verilator_lint.sh` then `./scripts/test_cpu.sh`.

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

# Fetch/build guest artifacts (not committed; gitignored under artifacts/)
scripts/fetch_build_seabios.sh          # → artifacts/seabios/bios.bin + dos_bios.bin
scripts/fetch_freedos_img.sh            # → artifacts/freedos/disk.img

# SeaBIOS POST (forced)
scripts/sim_tb_verilator.sh --tb tb/seabios_post_tb.sv -- \
  +SEABIOS_BIN=artifacts/seabios/bios.bin +REQUIRE_POST=1 +MAX_CYCLES=200000

# FreeDOS ladder to prompt + DIR (forced; real SeaBIOS, no TB VGA/IVT assist)
scripts/sim_tb_verilator.sh --tb tb/dos_boot_tb.sv -- \
  +SEABIOS_BIN=artifacts/seabios/bios.bin \
  +DISK_IMG=artifacts/freedos/disk.img \
  +REQUIRE_DOS=1 +MAX_CYCLES=5000000

# Optional local MS-DOS (not in CI): same plusargs with +DISK_IMG=/path/to/msdos.img

# Win95 ladder (legal local image)
scripts/sim_tb_verilator.sh --tb tb/win95_boot_tb.sv -- \
  +SEABIOS_BIN=/path/to/bios.bin +DISK_IMG=/path/to/win95.img \
  +MAX_CYCLES=200000000
```
