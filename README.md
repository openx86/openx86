# openx86

openx86 是一个面向 bring-up 和持续演进的 x86 SoC/CPU RTL 仓库。

- SoC 主线用于打通总线、芯片组、内存与外设路径。
- `i486_cpu` / `i486_cpu_core` 及相关子系统在 `rtl/cpu/` 下按 80386 功能块（BIU/IU/EU/MMU 等）组织，并配有分层 testbench。

## 当前目录结构

### RTL

- `rtl/openx86_soc_top.sv`：SoC 顶层
- `rtl/bus_controller.sv`：总线整合
- `rtl/chipset/`：825x、RTC、COM、LPT、PS2 等芯片组模块
- `rtl/common/`：ROM/RAM/边沿检测等公共模块
- `rtl/cpu/`：Intel486 风格目录（`top/`、`biu/`、`iu/`、`eu/`、`mmu/`、`pipe/` 等）与对应 `*.sv`
- `rtl/device/`：设备侧模块（如 `ide_controller`、`vga`、`ps2`）
- `rtl/memory/`：内存控制器
- `rtl/peripheral/`：外设协议/PHY 相关模块（如 SDCard）

### Testbench

`tb/` 已按 `rtl/` 代码结构重构：

- `tb/chipset/`
- `tb/common/`
- `tb/cpu/biu/`、`tb/cpu/iu/`、`tb/cpu/eu/`、`tb/cpu/wb/`（与 `rtl/cpu/` 功能划分一致）
- `tb/device/`
- `tb/memory/`
- `tb/peripheral/`
- `tb/top/`（SoC 顶层 TB）
- `tb/integration/`（系统集成类 TB）

## Filelist（单一事实来源）

为避免源文件集合漂移，仿真优先使用 `sim/filelists/*.f`：

- `sim/filelists/rtl.f`：默认 SoC/系统路径集合
- `sim/filelists/rtl_fullcore.f`：CPU 单测所需更完整集合
- `sim/filelists/rtl_experimental.f`：实验性集合
- `sim/filelists/tb.f`：testbench filelist（按需使用）

默认自动选择规则：

- TB 路径位于 `tb/cpu/**` 时，默认使用 `rtl_fullcore.f`
- 其他路径默认使用 `rtl.f`

## 快速运行

### Windows（PowerShell / iverilog）

SoC smoke test：

```powershell
./scripts/sim_soc.ps1
```

运行单个 TB：

```powershell
./scripts/sim_tb.ps1 -Tb tb/top/soc_top_tb.sv
```

分组回归：

```powershell
./scripts/test_soc.ps1
./scripts/test_bus.ps1
./scripts/test_chipset_periph.ps1
./scripts/test_memory_controller.ps1
./scripts/test_cpu.ps1
./scripts/test_all.ps1
```

### Linux/macOS（Verilator）

运行单个 TB：

```bash
scripts/sim_tb_verilator.sh --tb tb/top/soc_top_tb.sv
```

分组/全量回归：

```bash
scripts/test_soc.sh
scripts/test_bus.sh
scripts/test_chipset_periph.sh
scripts/test_memory_controller.sh
scripts/test_cpu.sh
scripts/test_all_verilator.sh
```

强制指定 filelist（示例）：

```bash
RTL_FILELIST=sim/filelists/rtl_experimental.f scripts/sim_tb_verilator.sh --tb tb/cpu/execute_unit/execute_unit_tb.sv
```

## 其他脚本

- `check_syntax.sh`：语法检查
- `test_all_modules.sh`：按可用仿真器（iverilog/vsim）运行模块测试
- `test_video_modules.sh`：VGA 相关 testbench 快速回归

## 约定

- 新增/重构 RTL 模块时，优先在 `tb/` 中按 `rtl/` 对应层级放置 testbench。
- SoC 顶层测试统一放在 `tb/top/`。
- 集成链路测试统一放在 `tb/integration/`。
