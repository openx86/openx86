// ============================================================================
// execute_arithmetic_mul
// ----------------------------------------------------------------------------
// 执行单元算术子模块：MUL（无符号乘法）结果计算。
//
// 说明：
// - 本文件通常只给出“乘法结果”的组合逻辑。
// - x86 的 MUL/IMUL 可能产生双倍宽度结果（例如 32x32 -> 64），以及影响 CF/OF。
//   具体截断/高低位选择由上层或其他单元决定。
// ============================================================================

module eu_ari_execute_arithmetic_mul #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 * operand_2;

endmodule
