// ============================================================================
// execute_shift_right
// ----------------------------------------------------------------------------
// 执行单元移位子模块：右移（SHR/SAR）。
// - `is_signed` 用于选择逻辑右移(0)或算术右移(1)的行为（高位填充 0 或符号位）。
// ============================================================================

module execute_shift_right #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand,
    input  logic [BIT_WIDTH-1:0] count,
    input  logic [BIT_WIDTH-1:0] is_signed,
    output logic [BIT_WIDTH-1:0] result
);

assign result = is_signed ?
{count'b0, operand[BIT_WIDTH-1:count]}
:
{count'{operand[BIT_WIDTH-1]}, operand[BIT_WIDTH-1:count]}
;

endmodule
