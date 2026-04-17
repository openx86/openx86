/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_8254_pit.
*/
// ============================================================================
// Intel 8254 PIT — 最小寄存器级模型（可综合）
// 主机接口：nCS/nRD/nWR + A[ 1: 0]（00–10 通道，11 控制字）
// 读端口返回当前计数低 8 位（简化）
// ============================================================================

module chip_8254_pit (
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic [ 1: 0]  i_a,
    input  logic [ 7: 0]  i_d,
    output logic [ 7: 0]  o_d,
    output logic        o_out0,
    output logic        o_out1,
    output logic        o_out2,
    input  logic        reset_n,
    input  logic        clock
);

    logic [15: 0] reload0, reload1, reload2;
    logic [15: 0] count0, count1, count2;
    logic [ 2: 0]  mode0, mode1, mode2;
    logic        wr_lo0, wr_lo1, wr_lo2;

    logic        out0_r, out1_r, out2_r;
    assign o_out0 = out0_r;
    assign o_out1 = out1_r;
    assign o_out2 = out2_r;

    logic wr = !i_cs_n && !i_wr_n;
    logic rd = !i_cs_n && !i_rd_n;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            reload0 <= 16'hFFFF;
            reload1 <= 16'hFFFF;
            reload2 <= 16'hFFFF;
            count0  <= 16'hFFFF;
            count1  <= 16'hFFFF;
            count2  <= 16'hFFFF;
            mode0   <= 3'd3;
            mode1   <= 3'd3;
            mode2   <= 3'd3;
            wr_lo0  <= 1'b1;
            wr_lo1  <= 1'b1;
            wr_lo2  <= 1'b1;
            out0_r  <= 1'b1;
            out1_r  <= 1'b1;
            out2_r  <= 1'b1;
        end else begin
            if (wr && i_a == 2'b11) begin
                if (i_d[ 7:  6] != 2'b11) begin
                    unique case (i_d[ 7:  6])
                        2'd0: begin
                            mode0 <= i_d[ 3:  1];
                            wr_lo0 <= 1'b1;
                        end
                        2'd1: begin
                            mode1 <= i_d[ 3:  1];
                            wr_lo1 <= 1'b1;
                        end
                        2'd2: begin
                            mode2 <= i_d[ 3:  1];
                            wr_lo2 <= 1'b1;
                        end
                        default: ;
                    endcase
                end
            end else if (wr && i_a != 2'b11) begin
                unique case (i_a)
                    2'd0: begin
                        if (wr_lo0) begin
                            reload0[ 7: 0] <= i_d;
                            wr_lo0 <= 1'b0;
                        end else begin
                            reload0[15:  8] <= i_d;
                            reload0 <= { i_d, reload0[ 7: 0] };
                            count0  <= ({ i_d, reload0[ 7: 0] } == 16'h0) ? 16'hFFFF : { i_d, reload0[ 7: 0] };
                            wr_lo0 <= 1'b1;
                        end
                    end
                    2'd1: begin
                        if (wr_lo1) begin
                            reload1[ 7: 0] <= i_d;
                            wr_lo1 <= 1'b0;
                        end else begin
                            reload1[15:  8] <= i_d;
                            reload1 <= { i_d, reload1[ 7: 0] };
                            count1  <= ({ i_d, reload1[ 7: 0] } == 16'h0) ? 16'hFFFF : { i_d, reload1[ 7: 0] };
                            wr_lo1 <= 1'b1;
                        end
                    end
                    2'd2: begin
                        if (wr_lo2) begin
                            reload2[ 7: 0] <= i_d;
                            wr_lo2 <= 1'b0;
                        end else begin
                            reload2[15:  8] <= i_d;
                            reload2 <= { i_d, reload2[ 7: 0] };
                            count2  <= ({ i_d, reload2[ 7: 0] } == 16'h0) ? 16'hFFFF : { i_d, reload2[ 7: 0] };
                            wr_lo2 <= 1'b1;
                        end
                    end
                    default: ;
                endcase
            end else begin
                if (count0 != 16'h0) begin
                    if (mode0 == 3'd3) begin
                        if (count0 <= 16'd2) begin
                            count0 <= reload0 == 16'h0 ? 16'hFFFF : reload0;
                            out0_r <= ~out0_r;
                        end else
                            count0 <= count0 - 16'd2;
                    end else begin
                        count0 <= count0 - 16'd1;
                        if (count0 == 16'd1) begin
                            out0_r <= ~out0_r;
                            count0 <= reload0 == 16'h0 ? 16'hFFFF : reload0;
                        end
                    end
                end
                if (count1 != 16'h0 && mode1 == 3'd3) begin
                    if (count1 <= 16'd2) begin
                        count1 <= reload1 == 16'h0 ? 16'hFFFF : reload1;
                        out1_r <= ~out1_r;
                    end else
                        count1 <= count1 - 16'd2;
                end
                if (count2 != 16'h0 && mode2 == 3'd3) begin
                    if (count2 <= 16'd2) begin
                        count2 <= reload2 == 16'h0 ? 16'hFFFF : reload2;
                        out2_r <= ~out2_r;
                    end else
                        count2 <= count2 - 16'd2;
                end
            end
        end
    end

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            unique case (i_a)
                2'd0: o_d = count0[ 7: 0];
                2'd1: o_d = count1[ 7: 0];
                2'd2: o_d = count2[ 7: 0];
                default:  o_d = 8'hFF;
            endcase
        end
    end

endmodule
