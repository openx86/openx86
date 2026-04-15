// ============================================================================
// execute_arithmetic_sbb.sv (historical filename)
// ----------------------------------------------------------------------------
// 注意：该文件当前定义的模块名为 `execute_arithmetic_sub`（普通减法）。
// 文件名与模块名不一致属于历史遗留；建议后续统一重命名并同步上层实例化点。
//
// 语义（SUB / subtract）：
// - `result = operand_1 - operand_2`
// - 仅输出结果；标志位更新通常由上层统一实现。
// ============================================================================

module execute_arithmetic_sub #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 - operand_2;

endmodule
