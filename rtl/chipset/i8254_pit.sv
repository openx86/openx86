// ============================================================================
// Intel 8254 PIT — 最小寄存器级模型（可综合）
// 0x40-0x42 通道，0x43 控制字（设置 access/mode）
// 读端口返回当前计数低 8 位（简化）
// ============================================================================

module i8254_pit (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    output logic        o_out0,
    output logic        o_out1,
    output logic        o_out2
);

    assign o_io_hit = (i_io_addr >= 16'h0040) && (i_io_addr <= 16'h0043);

    logic [15:0] reload0, reload1, reload2;
    logic [15:0] count0, count1, count2;
    logic [2:0]  mode0, mode1, mode2;
    logic        wr_lo0, wr_lo1, wr_lo2;

    logic        out0_r, out1_r, out2_r;
    assign o_out0 = out0_r;
    assign o_out1 = out1_r;
    assign o_out2 = out2_r;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
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
            if (i_io_valid && i_io_we && o_io_hit && i_io_addr == 16'h0043) begin
                if (i_io_wdata[7:6] != 2'b11) begin
                    unique case (i_io_wdata[7:6])
                        2'd0: begin
                            mode0 <= i_io_wdata[3:1];
                            wr_lo0 <= 1'b1;
                        end
                        2'd1: begin
                            mode1 <= i_io_wdata[3:1];
                            wr_lo1 <= 1'b1;
                        end
                        2'd2: begin
                            mode2 <= i_io_wdata[3:1];
                            wr_lo2 <= 1'b1;
                        end
                        default: ;
                    endcase
                end
            end else if (i_io_valid && i_io_we && o_io_hit) begin
                unique case (i_io_addr)
                    16'h0040: begin
                        if (wr_lo0) begin
                            reload0[7:0] <= i_io_wdata;
                            wr_lo0 <= 1'b0;
                        end else begin
                            reload0[15:8] <= i_io_wdata;
                            reload0 <= { i_io_wdata, reload0[7:0] };
                            count0  <= ({ i_io_wdata, reload0[7:0] } == 16'h0) ? 16'hFFFF : { i_io_wdata, reload0[7:0] };
                            wr_lo0 <= 1'b1;
                        end
                    end
                    16'h0041: begin
                        if (wr_lo1) begin
                            reload1[7:0] <= i_io_wdata;
                            wr_lo1 <= 1'b0;
                        end else begin
                            reload1[15:8] <= i_io_wdata;
                            reload1 <= { i_io_wdata, reload1[7:0] };
                            count1  <= ({ i_io_wdata, reload1[7:0] } == 16'h0) ? 16'hFFFF : { i_io_wdata, reload1[7:0] };
                            wr_lo1 <= 1'b1;
                        end
                    end
                    16'h0042: begin
                        if (wr_lo2) begin
                            reload2[7:0] <= i_io_wdata;
                            wr_lo2 <= 1'b0;
                        end else begin
                            reload2[15:8] <= i_io_wdata;
                            reload2 <= { i_io_wdata, reload2[7:0] };
                            count2  <= ({ i_io_wdata, reload2[7:0] } == 16'h0) ? 16'hFFFF : { i_io_wdata, reload2[7:0] };
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
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            unique case (i_io_addr)
                16'h0040: o_io_rdata = count0[7:0];
                16'h0041: o_io_rdata = count1[7:0];
                16'h0042: o_io_rdata = count2[7:0];
                default:  o_io_rdata = 8'hFF;
            endcase
        end
    end

endmodule
