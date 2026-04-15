// ============================================================================
// execute_arithmetic_sub.sv (historical filename)
// ----------------------------------------------------------------------------
// 注意：该文件当前定义的模块名为 `execute_arithmetic_sbb`（带借位减法）。
// 文件名与模块名不一致属于历史遗留；在 Quartus/Verilator/iverilog 这类“按文件列表编译”
// 的工程中通常不影响功能，但会影响可读性与后续维护。
//
// 语义（SBB / subtract with borrow）：
// - `result = operand_1 - operand_2 - carry_flag`
// - 仅输出结果；标志位更新通常由上层统一实现。
// ============================================================================

module execute_arithmetic_sbb #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    input  logic                 carry_flag,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 - operand_2 - carry_flag;

endmodule
