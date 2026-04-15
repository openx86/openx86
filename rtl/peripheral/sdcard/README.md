# SD 卡外设（纯控制器 + 共享盘映像）

本目录提供 **与 IDE 分离** 的 SD 协议侧逻辑，以及 **多主共享** 的盘映像 RAM。

## 架构

| 文件 | 说明 |
|------|------|
| `disk_ram_8.sv` | 8 位盘映像 RAM（双读口 A/B、单写口）。**IDE 用读口 A**；读口 B 预留给 SD 协议栈或卡模型。 |
| `sdcard_spi_host.sv` | **纯 SD SPI 主机**：`sck/mosi/miso/cs_n`，无 x86 I/O 端口；块读/写请求为占位 FSM，可扩展为完整 CMD/DATA。 |
| `disk_ram_8_tb.sv` | `disk_ram_8` + `ide_ata_pio`（`USE_INTERNAL_DISK_MEM=0`）集成测试。 |

CPU 侧 **仅通过 IDE**（`0x1F0–0x1F7` / `0x3F6`）访问硬盘：`rtl/chipset/pc_chipset_io.sv` 内例化 `disk_ram_8`，`ide_ata_pio` 使用 **外部盘** 读口 A。SD 主机与卡模型可在 SoC 顶层或仿真里再接到 **同一 `disk_ram_8` 的写口与读口 B**（例如块编程、脱机灌盘）。

## 与旧版区别

- 已移除混写 IDE 端口的单体 `sdcard_controller.sv`。
- 盘体统一为 `disk_ram_8`，便于将「SD 模拟介质」与 **IDE 主通道** 对接。

## 仿真

- `disk_ram_8_tb.sv`：根目录 `./test_all_modules.sh` 会自动编译 `disk_ram_8.sv` + `ide_ata_pio.sv`。
- `sdcard_spi_host_tb.sv`：仅测 SPI 主机占位。
