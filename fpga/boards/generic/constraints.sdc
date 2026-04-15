# ============================================================================
# Generic (board-agnostic) timing constraints
# ============================================================================
#
# 这是一个“占位/模板”约束文件，用于让 Quartus 工程可以先跑通分析流程。
# 实际上板时，请复制本目录为 `fpga/boards/<your_board>/` 并补齐：
# - 主时钟频率、复位约束
# - 引脚绑定（放在 .qsf 中）
# - I/O 标准、驱动强度、slew rate 等
#
# 约定：顶层端口名为 `clock` / `reset`（见 src/rtl/soc_top.sv）
#

# 例：50MHz 主时钟（按需修改）
create_clock -name clk -period 20.000 [get_ports {clock}]

# 例：异步复位（按需修改；若为同步复位可删除）
set_false_path -from [get_ports {reset}]

