/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_8254_pit.
*/
// ============================================================================
// Intel 8254 PIT — simplified synthesizable model
// - Implements control-word decode, RW formats (LSB/MSB/LSB->MSB), and counter
//   latch command.
// - Aligns Mode 0 / Mode 2 / Mode 3 output behavior with datasheet timing.
// - Keeps the existing project bus interface (single clock domain, no GATE pins).
// ============================================================================

module chip_8254_pit (
    input  logic         i_cs_n,      // 低有效片选
    input  logic         i_rd_n,      // 低有效读
    input  logic         i_wr_n,      // 低有效写
    input  logic [ 1: 0] i_a,         // 2'b11=控制字，其它=通道 0..2
    input  logic [ 7: 0] i_d,         // 写数据
    output logic [ 7: 0] o_d,         // 读数据
    output logic         o_out0,      // 通道 0 OUT（常用接 IRQ0）
    output logic         o_out1,      // 通道 1 OUT
    output logic         o_out2,      // 通道 2 OUT
    input  logic         reset_n,     // 异步低有效复位
    input  logic         clock         // 系统时钟（计数在此域递减）
);

    localparam logic [ 2: 0] LP_MODE0 = 3'd0;
    localparam logic [ 2: 0] LP_MODE1 = 3'd1;
    localparam logic [ 2: 0] LP_MODE2 = 3'd2;
    localparam logic [ 2: 0] LP_MODE3 = 3'd3;
    localparam logic [ 2: 0] LP_MODE4 = 3'd4;
    localparam logic [ 2: 0] LP_MODE5 = 3'd5;

    logic [16: 0] reload          [0:2];  // 有效重装载值（含 0→65536）
    logic [16: 0] count           [0:2];  // 当前计数值
    logic [16: 0] latch_count     [0:2];  // 锁存读快照
    logic [ 2: 0] mode            [0:2];  // 工作方式 0..5
    logic [ 1: 0] rw_fmt          [0:2];  // 读写格式（LSB/MSB/先后）
    logic          bcd_en         [0:2];  // 1=BCD 计数
    logic [ 7: 0] pending_lsb     [0:2];  // 16 位写时的低字节暂存
    logic          write_wait_msb [0:2];  // 尚缺 MSB 的半字写状态
    logic          load_pending   [0:2];  // 下一拍装入 reload→count
    logic          run_en         [0:2];  // 计数运行使能
    logic          out_r          [0:2];  // 通道 OUT 寄存
    logic          latch_valid    [0:2];  // 锁存读有效
    logic          read_msb_phase [0:2];  // 先后读时当前为高/低字节相位

    logic          mode2_low_pulse [0:2];   // 方式 2 低脉宽相位
    logic          mode45_low_pulse [0:2];  // 方式 4/5 低脉宽相位
    logic          mode3_phase_high [0:2];  // 方式 3 方波高半周标志
    logic [16: 0] mode3_high_ticks [0:2];
    logic [16: 0] mode3_low_ticks  [0:2];
    logic [16: 0] mode3_phase_ticks [0:2];

    logic wr;  // 写事务
    logic rd;  // 读事务

    assign wr = (!i_cs_n) && (!i_wr_n);
    assign rd = (!i_cs_n) && (!i_rd_n);

    assign o_out0 = out_r[0];
    assign o_out1 = out_r[1];
    assign o_out2 = out_r[2];

    function automatic logic [ 2: 0] f_decode_mode(input logic [ 2: 0] i_mode_raw);
        unique case (i_mode_raw)
            3'b000: f_decode_mode = LP_MODE0;
            3'b001: f_decode_mode = LP_MODE1;
            3'b010: f_decode_mode = LP_MODE2;
            3'b011: f_decode_mode = LP_MODE3;
            3'b100: f_decode_mode = LP_MODE4;
            3'b101: f_decode_mode = LP_MODE5;
            3'b110: f_decode_mode = LP_MODE2;
            3'b111: f_decode_mode = LP_MODE3;
            default: f_decode_mode = LP_MODE0;
        endcase
    endfunction

    function automatic logic [16: 0] f_bcd_to_count(input logic [15: 0] i_raw);
        int unsigned d0;
        int unsigned d1;
        int unsigned d2;
        int unsigned d3;
        int unsigned v;

        d0 = (i_raw[ 3: 0] > 4'd9) ? 32'd0 : 32'(i_raw[ 3: 0]);
        d1 = (i_raw[ 7: 4] > 4'd9) ? 32'd0 : 32'(i_raw[ 7: 4]);
        d2 = (i_raw[11: 8] > 4'd9) ? 32'd0 : 32'(i_raw[11: 8]);
        d3 = (i_raw[15:12] > 4'd9) ? 32'd0 : 32'(i_raw[15:12]);
        v  = (d3 * 1000) + (d2 * 100) + (d1 * 10) + d0;
        if (v == 0)
            f_bcd_to_count = 17'd10000;
        else
            f_bcd_to_count = v[16:0];
    endfunction

    function automatic logic [16: 0] f_effective_reload(
        input logic [15: 0] i_raw,
        input logic [ 2: 0] i_mode,
        input logic         i_bcd
    );
        logic [16: 0] v;
        if (i_bcd)
            v = f_bcd_to_count(i_raw);
        else
            v = (i_raw == 16'h0000) ? 17'd65536 : { 1'b0, i_raw };

        if (((i_mode == LP_MODE2) || (i_mode == LP_MODE3)) && (v < 17'd2))
            v = 17'd2;

        f_effective_reload = v;
    endfunction

    function automatic logic [16: 0] f_mode3_high_ticks(input logic [16: 0] i_reload);
        f_mode3_high_ticks = (i_reload + 17'd1) >> 1;
    endfunction

    function automatic logic [16: 0] f_mode3_low_ticks(input logic [16: 0] i_reload);
        f_mode3_low_ticks = i_reload >> 1;
    endfunction

    function automatic logic [15: 0] f_count_to_bcd(input logic [16: 0] i_count);
        int unsigned v;
        int unsigned d0;
        int unsigned d1;
        int unsigned d2;
        int unsigned d3;

        v  = (i_count == 17'd10000) ? 32'd0 : 32'(i_count);
        v  = v % 10000;
        d3 = v / 1000;
        v  = v % 1000;
        d2 = v / 100;
        v  = v % 100;
        d1 = v / 10;
        d0 = v % 10;
        f_count_to_bcd = { d3[3:0], d2[3:0], d1[3:0], d0[3:0] };
    endfunction

    function automatic logic [15: 0] f_count_to_bus(
        input logic [16: 0] i_count,
        input logic         i_bcd
    );
        if (i_bcd)
            f_count_to_bus = f_count_to_bcd(i_count);
        else if (i_count == 17'd65536)
            f_count_to_bus = 16'h0000;
        else
            f_count_to_bus = i_count[15:0];
    endfunction

    function automatic logic [ 7: 0] f_pick_read_byte(
        input logic [15: 0] i_value,
        input logic [ 1: 0] i_rw,
        input logic         i_msb_phase
    );
        unique case (i_rw)
            2'b01: f_pick_read_byte = i_value[ 7: 0];
            2'b10: f_pick_read_byte = i_value[15: 8];
            2'b11: f_pick_read_byte = i_msb_phase ? i_value[15: 8] : i_value[ 7: 0];
            default: f_pick_read_byte = i_value[ 7: 0];
        endcase
    endfunction

    // 控制字/通道数据写、锁存命令、各方式计数与 OUT 波形更新；以及读相位。
    always_ff @(posedge clock or negedge reset_n) begin
        logic [ 1: 0] ch;
        logic [ 1: 0] cw_rw;
        logic [ 2: 0] cw_mode;
        logic [15: 0] raw_count;
        logic [16: 0] new_reload;

        if (~reset_n) begin
            for (int ri = 0; ri < 3; ri = ri + 1) begin
                reload[ri]           <= 17'd65536;
                count[ri]            <= 17'd65536;
                latch_count[ri]      <= 17'd0;
                mode[ri]             <= LP_MODE3;
                rw_fmt[ri]           <= 2'b11;
                bcd_en[ri]           <= 1'b0;
                pending_lsb[ri]      <= 8'h00;
                write_wait_msb[ri]   <= 1'b1;
                load_pending[ri]     <= 1'b0;
                run_en[ri]           <= 1'b0;
                out_r[ri]            <= 1'b1;
                latch_valid[ri]      <= 1'b0;
                read_msb_phase[ri]   <= 1'b0;
                mode2_low_pulse[ri]  <= 1'b0;
                mode45_low_pulse[ri] <= 1'b0;
                mode3_phase_high[ri] <= 1'b1;
                mode3_high_ticks[ri] <= 17'd1;
                mode3_low_ticks[ri]  <= 17'd1;
                mode3_phase_ticks[ri] <= 17'd1;
            end
        end else begin
            if (wr && (i_a == 2'b11)) begin
                if (i_d[ 7: 6] != 2'b11) begin
                    ch    = i_d[ 7:  6];
                    cw_rw = i_d[ 5: 4];

                    if (cw_rw == 2'b00) begin
                        latch_count[ch]    <= count[ch];
                        latch_valid[ch]    <= 1'b1;
                        read_msb_phase[ch] <= 1'b0;
                    end else begin
                        cw_mode = f_decode_mode(i_d[ 3: 1]);

                        mode[ch]             <= cw_mode;
                        rw_fmt[ch]           <= cw_rw;
                        bcd_en[ch]           <= i_d[0];
                        write_wait_msb[ch]   <= (cw_rw == 2'b11);
                        load_pending[ch]     <= 1'b0;
                        run_en[ch]           <= 1'b0;
                        latch_valid[ch]      <= 1'b0;
                        read_msb_phase[ch]   <= 1'b0;
                        mode2_low_pulse[ch]  <= 1'b0;
                        mode45_low_pulse[ch] <= 1'b0;
                        mode3_phase_high[ch] <= 1'b1;
                        mode3_high_ticks[ch] <= 17'd1;
                        mode3_low_ticks[ch]  <= 17'd1;
                        mode3_phase_ticks[ch] <= 17'd1;

                        if (cw_mode == LP_MODE0)
                            out_r[ch] <= 1'b0;
                        else
                            out_r[ch] <= 1'b1;
                    end
                end
            end else if (wr && (i_a != 2'b11)) begin
                ch = i_a[ 1: 0];

                unique case (rw_fmt[ch])
                    2'b01: begin
                        // 只写低字节
                        raw_count = { 8'h00, i_d };
                        new_reload = f_effective_reload(raw_count, mode[ch], bcd_en[ch]);

                        reload[ch]           <= new_reload;
                        load_pending[ch]     <= 1'b1;
                        run_en[ch]           <= 1'b1;
                        write_wait_msb[ch]   <= 1'b1;
                        latch_valid[ch]      <= 1'b0;
                        read_msb_phase[ch]   <= 1'b0;
                        mode2_low_pulse[ch]  <= 1'b0;
                        mode45_low_pulse[ch] <= 1'b0;

                        if (mode[ch] == LP_MODE0)
                            out_r[ch] <= 1'b0;
                    end
                    2'b10: begin
                        // 只写高字节
                        raw_count = { i_d, 8'h00 };
                        new_reload = f_effective_reload(raw_count, mode[ch], bcd_en[ch]);

                        reload[ch]           <= new_reload;
                        load_pending[ch]     <= 1'b1;
                        run_en[ch]           <= 1'b1;
                        write_wait_msb[ch]   <= 1'b1;
                        latch_valid[ch]      <= 1'b0;
                        read_msb_phase[ch]   <= 1'b0;
                        mode2_low_pulse[ch]  <= 1'b0;
                        mode45_low_pulse[ch] <= 1'b0;

                        if (mode[ch] == LP_MODE0)
                            out_r[ch] <= 1'b0;
                    end
                    2'b11: begin
                        // 先低后高
                        if (write_wait_msb[ch]) begin
                            pending_lsb[ch]    <= i_d;
                            write_wait_msb[ch] <= 1'b0;
                            latch_valid[ch]    <= 1'b0;
                            read_msb_phase[ch] <= 1'b0;

                            if (mode[ch] == LP_MODE0) begin
                                run_en[ch] <= 1'b0;
                                out_r[ch]  <= 1'b0;
                            end
                        end else begin
                            raw_count = { i_d, pending_lsb[ch] };
                            new_reload = f_effective_reload(raw_count, mode[ch], bcd_en[ch]);

                            reload[ch]           <= new_reload;
                            load_pending[ch]     <= 1'b1;
                            run_en[ch]           <= 1'b1;
                            write_wait_msb[ch]   <= 1'b1;
                            latch_valid[ch]      <= 1'b0;
                            read_msb_phase[ch]   <= 1'b0;
                            mode2_low_pulse[ch]  <= 1'b0;
                            mode45_low_pulse[ch] <= 1'b0;

                            if (mode[ch] == LP_MODE0)
                                out_r[ch] <= 1'b0;
                        end
                    end
                    default: begin
                        write_wait_msb[ch] <= 1'b1;
                    end
                endcase
            end else begin
                for (ch = 0; ch < 3; ch = ch + 1) begin
                    if (load_pending[ch]) begin
                        load_pending[ch]    <= 1'b0;
                        run_en[ch]          <= 1'b1;
                        count[ch]           <= reload[ch];
                        mode2_low_pulse[ch] <= 1'b0;
                        mode45_low_pulse[ch] <= 1'b0;

                        if (mode[ch] == LP_MODE0 || mode[ch] == LP_MODE1)
                            out_r[ch] <= 1'b0;
                        else
                            out_r[ch] <= 1'b1;

                        if (mode[ch] == LP_MODE3) begin
                            mode3_phase_high[ch] <= 1'b1;
                            mode3_high_ticks[ch] <= f_mode3_high_ticks(reload[ch]);
                            mode3_low_ticks[ch]  <= f_mode3_low_ticks(reload[ch]);
                            mode3_phase_ticks[ch] <= f_mode3_high_ticks(reload[ch]);
                        end
                    end else if (run_en[ch]) begin
                        unique case (mode[ch])
                            LP_MODE0,
                            LP_MODE1: begin
                                // 方式 0/1：减计数至 0 拉高 OUT
                                if (count[ch] > 17'd1) begin
                                    count[ch] <= count[ch] - 17'd1;
                                end else if (count[ch] == 17'd1) begin
                                    count[ch] <= 17'd0;
                                    out_r[ch] <= 1'b1;
                                    run_en[ch] <= 1'b0;
                                end
                            end
                            LP_MODE2: begin
                                // 方式 2：速率发生器，低脉宽固定 1 拍
                                if (mode2_low_pulse[ch]) begin
                                    mode2_low_pulse[ch] <= 1'b0;
                                    out_r[ch]           <= 1'b1;
                                    count[ch]           <= reload[ch];
                                end else if (count[ch] > 17'd2) begin
                                    count[ch] <= count[ch] - 17'd1;
                                end else begin
                                    count[ch]          <= 17'd1;
                                    out_r[ch]          <= 1'b0;
                                    mode2_low_pulse[ch] <= 1'b1;
                                end
                            end
                            LP_MODE3: begin
                                // 方式 3：方波，高低半周按 reload 折半
                                if (mode3_phase_ticks[ch] > 17'd1) begin
                                    mode3_phase_ticks[ch] <= mode3_phase_ticks[ch] - 17'd1;
                                end else if (mode3_phase_high[ch]) begin
                                    mode3_phase_high[ch] <= 1'b0;
                                    out_r[ch] <= 1'b0;
                                    if (mode3_low_ticks[ch] == 17'd0)
                                        mode3_phase_ticks[ch] <= 17'd1;
                                    else
                                        mode3_phase_ticks[ch] <= mode3_low_ticks[ch];
                                end else begin
                                    mode3_phase_high[ch] <= 1'b1;
                                    out_r[ch] <= 1'b1;
                                    if (mode3_high_ticks[ch] == 17'd0)
                                        mode3_phase_ticks[ch] <= 17'd1;
                                    else
                                        mode3_phase_ticks[ch] <= mode3_high_ticks[ch];
                                end

                                if (count[ch] > 17'd1)
                                    count[ch] <= count[ch] - 17'd1;
                                else
                                    count[ch] <= reload[ch];
                            end
                            LP_MODE4,
                            LP_MODE5: begin
                                // 方式 4/5：软件触发脉冲
                                if (mode45_low_pulse[ch]) begin
                                    mode45_low_pulse[ch] <= 1'b0;
                                    out_r[ch]            <= 1'b1;
                                    run_en[ch]           <= 1'b0;
                                end else if (count[ch] > 17'd1) begin
                                    count[ch] <= count[ch] - 17'd1;
                                end else if (count[ch] == 17'd1) begin
                                    count[ch]           <= 17'd0;
                                    out_r[ch]           <= 1'b0;
                                    mode45_low_pulse[ch] <= 1'b1;
                                end
                            end
                            default: begin
                                if (count[ch] > 17'd1)
                                    count[ch] <= count[ch] - 17'd1;
                                else if (count[ch] == 17'd1) begin
                                    count[ch] <= 17'd0;
                                    out_r[ch] <= 1'b1;
                                    run_en[ch] <= 1'b0;
                                end
                            end
                        endcase
                    end
                end
            end

            if (rd && (i_a != 2'b11)) begin
                ch = i_a[ 1: 0];
                if (rw_fmt[ch] == 2'b11) begin
                    if (read_msb_phase[ch]) begin
                        read_msb_phase[ch] <= 1'b0;
                        if (latch_valid[ch])
                            latch_valid[ch] <= 1'b0;
                    end else begin
                        read_msb_phase[ch] <= 1'b1;
                    end
                end else begin
                    if (latch_valid[ch])
                        latch_valid[ch] <= 1'b0;
                end
            end
        end
    end

    // 读数据口：锁存或当前 count，按 RW 格式拼字节。
    always_comb begin
        logic [15: 0] read0;
        logic [15: 0] read1;
        logic [15: 0] read2;

        read0 = latch_valid[0] ? f_count_to_bus(latch_count[0], bcd_en[0]) : f_count_to_bus(count[0], bcd_en[0]);
        read1 = latch_valid[1] ? f_count_to_bus(latch_count[1], bcd_en[1]) : f_count_to_bus(count[1], bcd_en[1]);
        read2 = latch_valid[2] ? f_count_to_bus(latch_count[2], bcd_en[2]) : f_count_to_bus(count[2], bcd_en[2]);

        o_d = 8'hFF;
        if (rd) begin
            unique case (i_a)
                2'd0: o_d = f_pick_read_byte(read0, rw_fmt[0], read_msb_phase[0]);
                2'd1: o_d = f_pick_read_byte(read1, rw_fmt[1], read_msb_phase[1]);
                2'd2: o_d = f_pick_read_byte(read2, rw_fmt[2], read_msb_phase[2]);
                default: o_d = 8'hFF;
            endcase
        end
    end

endmodule
