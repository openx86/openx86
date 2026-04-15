# openx86

本仓库包含一个 **bring-up 级** 的 x86 SoC 顶层（用于快速跑通总线/内存/BIOS/VGA 等系统路径），以及一套仍在演进中的 `w686_*` CPU RTL（用于更完整的指令/流水/寄存器/MMU 等单元测试）。

## 目录结构（高层）
- **`src/rtl/`**：主要 RTL 实现
  - `src/rtl/soc_top.sv`：当前 SoC 主线顶层（默认综合/默认系统仿真）
  - `src/rtl/x86_core_top.sv`：bring-up 级 CPU wrapper（最小指令集用于 smoke test）
  - `src/rtl/cpu/`：`w686_*` CPU 与相关单元（可选，主要供 CPU 单测）
  - `src/rtl/experimental/`：草稿/实验性 RTL（默认不进入 CI）
- **`tb/`**：testbenches
- **`scripts/`**：仿真/测试脚本
- **`sim/filelists/`**：RTL filelist（“权威源文件集合”）

## RTL filelist（单一事实来源）
为避免脚本/工程各自扫描目录导致源文件集合漂移，本仓库用 filelist 固化 RTL 集合：
- **`sim/filelists/rtl.f`**：默认 bring-up SoC 集合（`soc_top` + 外设/芯片组）
- **`sim/filelists/rtl_fullcore.f`**：CPU 单测用的更大集合（包含 `w686_*` 与依赖）
- **`sim/filelists/rtl_experimental.f`**：实验性集合（包含 `src/rtl/experimental/`）

## 快速运行（Windows / PowerShell）
- **系统级 smoke test（SoC）**：

```powershell
./scripts/sim_soc.ps1
```

- **运行单个 TB（iverilog）**：

```powershell
./scripts/sim_tb.ps1 -Tb tb/system/soc_top_tb.sv
```

脚本会根据 TB 路径自动选择 filelist（`tb/unit/cpu/**`、`tb/unit/core/**` 默认用 `rtl_fullcore.f`）。

## Linux / macOS（verilator）
- **运行单个 TB（verilator）**：

```bash
scripts/sim_tb_verilator.sh --tb tb/system/soc_top_tb.sv
```

如需强制指定 filelist，可用环境变量（示例）：

```bash
RTL_FILELIST=sim/filelists/rtl_experimental.f scripts/sim_tb_verilator.sh --tb tb/unit/cpu/execute_unit/execute_unit_tb.sv
```
