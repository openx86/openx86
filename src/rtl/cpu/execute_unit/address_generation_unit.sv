// ============================================================================
// Address Generation Unit (AGU)
// 有效地址 = base + index * {1,2,4,8} + displacement（32 位有符号扩展）
// 用于 ModR/M、SIB 寻址；段基址/分页在 MMU 侧叠加
// ============================================================================

module address_generation_unit (
    input  logic [31:0] i_base,
    input  logic [31:0] i_index,
    input  logic [ 1:0] i_scale,
    input  logic [31:0] i_disp,
    output logic [31:0] o_effective_address
);

    logic [63:0] scaled;
    logic [63:0] sum;

    always_comb begin
        unique case (i_scale)
            2'd0: scaled = {32'h0, i_index} * 64'd1;
            2'd1: scaled = {32'h0, i_index} * 64'd2;
            2'd2: scaled = {32'h0, i_index} * 64'd4;
            default: scaled = {32'h0, i_index} * 64'd8;
        endcase
    end

    assign sum = {32'h0, i_base} + scaled + {{32{i_disp[31]}}, i_disp};
    assign o_effective_address = sum[31:0];

endmodule
