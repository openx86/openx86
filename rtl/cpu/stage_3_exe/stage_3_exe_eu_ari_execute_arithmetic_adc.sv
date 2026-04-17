// ============================================================================
// execute_arithmetic_adc
// ----------------------------------------------------------------------------
// 执行单元算术子模块：ADC（Add with Carry）。
//
// 语义：
// - `result = operand_1 + operand_2 + carry_flag`
// - 该文件当前仅输出加法结果；标志位（CF/OF/...）若需要应由上层统一计算。
// ============================================================================

module stage_3_exe_eu_ari_execute_arithmetic_adc #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    input  logic                 carry_flag,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 + operand_2 + carry_flag;

endmodule
