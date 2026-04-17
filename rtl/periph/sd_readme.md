# SD 卡外设（纯控制器 + 共享盘映像）

本目录提供 **与 IDE 分离** 的 SD 协议侧逻辑，以及 **多主共享** 的盘映像 RAM。

## 架构

| 文件 | 说明 |
|------|------|
| `sd_disk_ram_8.sv` | 8 位盘映像 RAM（双读口 A/B、单写口）。**IDE 用读口 A**；读口 B 预留给 SD 协议栈或卡模型。 |
| `sd_4bit_phy.sv` | SDIO 物理层：CMD/DAT 开漏与 CLK 输出，供片内主机驱动板级 SD 插座。 |
| `sd_native_host_4bit.sv` | SDIO 4-bit 主机（CMD + 数据阶段 FSM），由 `ide_sd_sector_bridge` 触发块读。 |
| `ide_sd_sector_bridge.sv` | IDE 扇区请求与 SD 主机之间的握手与缓冲。 |
| `disk_ram_8_tb.sv` | `disk_ram_8` + `chip_ata_ide`（`USE_INTERNAL_DISK_MEM=0`）集成测试。 |

CPU 侧 **仅通过 IDE**（`0x1F0–0x1F7` / `0x3F6`）访问硬盘：`rtl/bus_controller.sv` 的 `bus_devices` 内例化 `disk_ram_8`，`chip_ata_ide` 使用 **外部盘** 读口 A。SD 主机与卡模型可在 SoC 顶层或仿真里再接到 **同一 `disk_ram_8` 的写口与读口 B**（例如块编程、脱机灌盘）。

## 与旧版区别

- 已移除混写 IDE 端口的单体 `sdcard_controller.sv`。
- 盘体统一为 `disk_ram_8`，便于将「SD 模拟介质」与 **IDE 主通道** 对接。

## 仿真

- `disk_ram_8_tb.sv`：根目录 `./test_all_modules.sh` 会自动编译 `sd_disk_ram_8.sv` + `chip_ata_ide.sv`。
- `ide_sd_native_disk_tb.sv`：IDE + SDIO 主机 + 原生卡模型读扇区路径。
