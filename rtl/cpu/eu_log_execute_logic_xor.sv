// ============================================================================
// execute_logic_xor
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：XOR（按位异或）。
// ============================================================================

module eu_log_execute_logic_xor #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 ^ operand_2;

endmodule
