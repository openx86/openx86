// ============================================================================
// IBM PC 并行口（LPT1）— Centronics 风格寄存器级模型
// 0x378 数据、0x379 状态、0x37A 控制；0x37B–0x37F 读回 0xFF
// 状态位与 PC 一致：Busy/ACK 等为反相有效（读时按常见 BIOS 期望编码）
// ============================================================================

module lpt_centronics #(
    parameter logic [15:0] PORT_BASE = 16'h0378
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit
);

    assign o_io_hit = (i_io_addr >= PORT_BASE) && (i_io_addr <= PORT_BASE + 16'h7);

    wire [2:0] off = i_io_addr[2:0];

    logic [7:0] data_reg;
    logic [7:0] ctrl_reg;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            data_reg <= 8'h0;
            ctrl_reg <= 8'h0C;
        end else if (i_io_valid && i_io_we && o_io_hit) begin
            unique case (off)
                3'd0: data_reg <= i_io_wdata;
                3'd2: ctrl_reg <= i_io_wdata;
                default: ;
            endcase
        end
    end

    wire [7:0] status_read = {
        1'b0,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b0,
        1'b1,
        1'b1
    };

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            unique case (off)
                3'd0: o_io_rdata = data_reg;
                3'd1: o_io_rdata = status_read;
                3'd2: o_io_rdata = ctrl_reg;
                default: o_io_rdata = 8'hFF;
            endcase
        end
    end

endmodule
