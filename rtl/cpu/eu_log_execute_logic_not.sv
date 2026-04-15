// ============================================================================
// execute_logic_not
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：NOT（按位取反）。
// ============================================================================

module eu_log_execute_logic_not #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    output logic [BIT_WIDTH-1:0] result
);

assign result = ~operand_1;

endmodule
