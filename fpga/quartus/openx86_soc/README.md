# Quartus 工程：openx86_soc

## 目标
用 Quartus Prime 打开/综合 `src/rtl/soc_top.sv`（顶层实体 `soc_top`），并且复用仓库的仿真 filelist（`sim/filelists/rtl.f`）来管理源文件集合与 include/search path。

## 快速开始
- **生成/更新工程**

```bash
quartus_sh -t fpga/quartus/openx86_soc/create_project.tcl
```

- **打开工程**
  - 用 Quartus GUI 打开 `fpga/quartus/openx86_soc/openx86_soc.qpf`

## 板卡适配
- 当前默认使用 `fpga/boards/generic/constraints.sdc`（仅提供模板时钟约束）。
- 上板时建议：
  - 复制 `fpga/boards/generic` 到 `fpga/boards/<your_board>`
  - 增加 pin/IOStandard 等约束（通常放 `.qsf` 或 board 专用 Tcl）
  - 修改 `create_project.tcl` 选择对应 board 的约束文件

