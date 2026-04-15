# Phase 0 — 总体架构（openx86 / 80386 子集，DOS 优先）

## 1. 目标与约束

- 在 FPGA 上构成最小 IBM PC 兼容 SoC：BIOS → 引导 → **实模式 DOS** 优先；Windows 98 依赖保护模式、分页、中断与外设，分期完成。
- RTL：**可综合 SystemVerilog**；控制用 **FSM + valid/ready**；RTL 避免 `#delay`、`initial` 驱动逻辑（ROM `initial` `$readmem` 仅用于存储初始化属常见综合例外）。
- **演进策略**：以 `rtl/core/x86_core_top.sv` 为 CPU 主干，按阶段扩展 decode / microcode / execute / 寄存器，不再造平行顶层设计。

## 2. SoC 框图

```
          +------------------+
  clk/rst |  x86_core_top    |
 -------->| fetch->decode    |
          | ->uop->exec->wb  |
          +--------+---------+
                   | mem/io master
                   v
          +--------+---------+
          |      bus.sv      |--> RAM 0x00000-0x9FFFF
          |  IBM PC 解码     |--> VRAM / BIOS ROM / I/O
          +--------+---------+
                   v
          +------------------+
          | UART/PIT/VGA…    |（分期）
          +------------------+
```

## 3. 微架构

- **多周期、可停顿总线**：取指多拍突发读；设备用 `i_bus_ready` 拉伸。
- **宏指令 → 单微操作（Phase 1）**：每条已支持宏指令对应 1 条 uop，微码模块用 FSM 锁存宏指令再发射，避免 `macro_valid` 单拍丢失。

## 4. 指令子集（分期）

- **Phase 1（实模式 16 位默认）**：`MOV`（r16/imm16、`8B` reg-reg）、`ADD/SUB/CMP`（`AX` 与 imm16；`01`/`29`/`39` reg-reg）、短跳转 `EB`、`JE/JNE`（`74`/`75`）、`HLT`；可通过 **`0x66` 前缀** 在实模式下使用 **32 位操作（如 `B8` + imm32）** 兼容已有测例。
- **后续**：栈/CALL/INT、段与保护模式、分页、IDT、外设等按原计划 Phase 2+。

## 5. 存储模型（摘要）

- **实模式线性地址**：`(CS<<4)+IP`（`EIP[15:0]` 为 IP）；`0x66` 仅影响操作数宽度，不改变地址形成。
- **保护模式 / 分页**：结构与 walk 策略见规划文档；当前核心保留 `CR0.PE` 与 `CS.base` 钩子。

## 6. FPGA 建议

- 单时钟 **50–100 MHz**；RAM/BIOS 推断 **BRAM**；分页可走多拍组合逻辑。
- 顶层：`PLL` + 同步复位在 `fpga_top`（Phase 8），核心 RTL 与厂商无关。

## 7. 验证

- 每模块 `*_tb.sv`（SystemVerilog）；CPU 级 TB 灌机器码、比对寄存器、可选 **trace**。
- SoC：`soc_top_tb` 走 **CPU + bus + RAM + BIOS ROM** 冒烟路径。

详见实现：`rtl/core/`、`rtl/soc_top.sv`、`rtl/bus.sv`。

## 8. 仿真脚本（需安装 Icarus Verilog）

- `scripts/sim_x86_core.ps1` — CPU + `x86_core_top_tb`
- `scripts/sim_soc.ps1` — `soc_top` + 总线 + RAM/BIOS

类型定义在包 `rtl/core/x86_types_pkg.sv` 中；各模块使用 `import openx86_types_pkg::*;`。

## 9. Phase 2 — 存储与总线（已实现）

- **`rtl/bus.sv`**：IBM PC 兼容地址译码（已有）。
- **`rtl/ram.sv`**：`sys_ram` — 32 位字、字节地址 `byte_addr[19:0]`，内部用 `byte_addr[19:2]` 寻址字。
- **`rtl/rom.sv`**：`sys_rom`（参数化/可选 `$readmemh`）、`bios_rom_bootstub`（64K 字 BIOS + 与 core_tb 一致的复位测试码）。
- **`rtl/soc_top.sv`**：CPU + bus + `sys_ram` + `bios_rom_bootstub` + 扩展 BIOS `sys_rom`。
- **TB**：`rtl/ram_tb.sv`、`rtl/rom_tb.sv`、`rtl/soc_top_tb.sv`; 脚本 `scripts/sim_ram_tb.ps1`、`scripts/sim_rom_tb.ps1`、`scripts/sim_soc.ps1`。
