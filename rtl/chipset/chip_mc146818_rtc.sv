/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_mc146818_rtc.
*/
// ============================================================================
// MC146818 兼容 RTC/CMOS（IBM PC/AT 语义）
// 0x70: 索引低 7 位；bit7 = NMI 屏蔽（仅存储，不参与寻址）
// 0x71: 数据口
// Reg A(0x0A): DV[6:4]+RS[3:0] 可写；UIP(7) 在每秒末约 244µs 内置 1（近似）
// Reg B(0x0B): SET 冻结日历；DM 选 BCD/二进制；bit1=1 为 24 小时
// Reg C(0x0C): 只读，读清 PF/AF/UF/IRQF；写忽略
// Reg D(0x0D): 只读 VRT(7)=1；写忽略
// 世纪寄存器 0x32 → cmos_ram[50]，按 BCD 解释（与常见 BIOS 一致）
// UIP/PIE 周期与实芯片分频器可能略有偏差。
// ============================================================================

module chip_mc146818_rtc #(
    parameter int CLK_HZ = 8_000
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    // 0 = 索引口 0x70，1 = 数据口 0x71
    input  logic        i_a0,
    input  logic [7:0]  i_d,
    output logic [7:0]  o_d,
    output logic        o_rtc_irq
);

    localparam int UIP_CYC = ((CLK_HZ * 244) / 1_000_000) > 0 ? ((CLK_HZ * 244) / 1_000_000) : 1;
    localparam int CW      = $clog2(CLK_HZ + 1);
    localparam logic [CW-1:0] SUB_LAST = CW'(CLK_HZ - 1);
    localparam logic [CW-1:0] UIP_START = (CLK_HZ > UIP_CYC) ? CW'(CLK_HZ - UIP_CYC) : CW'(0);

    wire wr = !i_cs_n && !i_wr_n;
    wire rd = !i_cs_n && !i_rd_n;

    logic [7:0] index_reg;
    logic [7:0] cmos_ram [0:127];

    wire dm_bin   = cmos_ram[11][2];
    wire mode_24h = cmos_ram[11][1];
    wire set_stop = cmos_ram[11][7];
    wire pie_en   = cmos_ram[11][6];
    wire aie_en   = cmos_ram[11][5];
    wire uie_en   = cmos_ram[11][4];

    logic [5:0] sec_bin, min_bin;
    logic [4:0] hour_bin;
    logic [2:0] dow_bin;
    logic [4:0] dom_bin;
    logic [3:0] month_bin;
    logic [7:0] year_bin;

    logic [CW-1:0] sub_sec;
    logic          uip_phase;

    logic reg_c_pf, reg_c_af, reg_c_uf, reg_c_irqf;

    logic [23:0] pie_div;
    logic [23:0] pie_reload_q;
    logic        alarm_match_d;

    wire read_c_pulse = rd && i_a0 && (index_reg[6:0] == 7'h0C);
    logic read_c_d1;

    function automatic logic [7:0] u8_to_bcd(input logic [7:0] v);
        logic [7:0] t;
        t = v > 8'd99 ? 8'd99 : v;
        u8_to_bcd = {4'(t / 10), 4'(t % 10)};
    endfunction

    function automatic logic [7:0] u6_to_bcd(input logic [5:0] v);
        logic [5:0] t;
        t = v > 6'd59 ? 6'd59 : v;
        u6_to_bcd = {2'b0, 4'(t / 10), 4'(t % 10)};
    endfunction

    function automatic logic [7:0] u5_to_bcd_hour(input logic [4:0] v);
        logic [4:0] t;
        t = v > 5'd23 ? 5'd23 : v;
        u5_to_bcd_hour = {1'b0, 3'(t / 10), 4'(t % 10)};
    endfunction

    function automatic logic [7:0] bcd_to_u8(input logic [7:0] b);
        logic [3:0] hi, lo;
        hi = b[7:4];
        lo = b[3:0];
        if (hi > 4'd9 || lo > 4'd9)
            bcd_to_u8 = 8'd0;
        else
            bcd_to_u8 = 8'(hi * 4'd10 + lo);
    endfunction

    function automatic logic [5:0] bcd_to_u6(input logic [7:0] b);
        logic [3:0] hi, lo;
        hi = b[7:4];
        lo = b[3:0];
        if (hi > 4'd5 || lo > 4'd9)
            bcd_to_u6 = 6'd0;
        else
            bcd_to_u6 = 6'(hi * 4'd10 + lo);
    endfunction

    function automatic logic [4:0] bcd_to_u5_hour(input logic [7:0] b);
        logic [3:0] hi, lo;
        hi = b[7:4];
        lo = b[3:0];
        if (hi > 4'd2 || lo > 4'd9)
            bcd_to_u5_hour = 5'd0;
        else if (8'(hi * 4'd10 + lo) > 8'd23)
            bcd_to_u5_hour = 5'd23;
        else
            bcd_to_u5_hour = 5'(hi * 4'd10 + lo);
    endfunction

    function automatic int century_bcd(input logic [7:0] cf);
        century_bcd = bcd_to_u8(cf);
    endfunction

    function automatic int full_year(input logic [7:0] cent_bcd, input logic [7:0] ybin);
        full_year = century_bcd(cent_bcd) * 100 + ybin;
    endfunction

    function automatic logic leap_y(input int y);
        return (y % 4 == 0) && ((y % 100 != 0) || (y % 400 == 0));
    endfunction

    function automatic int dim(input int m, input int y);
        unique case (m)
            1, 3, 5, 7, 8, 10, 12: dim = 31;
            4, 6, 9, 11: dim = 30;
            2: dim = leap_y(y) ? 29 : 28;
            default: dim = 31;
        endcase
    endfunction

    function automatic logic [7:0] enc_sec_min(
        input logic [5:0] binv,
        input logic bin_mode
    );
        enc_sec_min = bin_mode ? {2'b0, binv} : u6_to_bcd(binv);
    endfunction

    function automatic logic [7:0] enc_hour(
        input logic [4:0] h24,
        input logic bin_mode,
        input logic is_24h
    );
        logic [4:0] h12v;
        logic pm;
        if (is_24h) begin
            enc_hour = bin_mode ? {3'b0, h24} : u5_to_bcd_hour(h24);
        end else begin
            if (h24 == 0) begin
                h12v = 5'd12;
                pm   = 1'b0;
            end else if (h24 < 12) begin
                h12v = h24;
                pm   = 1'b0;
            end else if (h24 == 12) begin
                h12v = 5'd12;
                pm   = 1'b1;
            end else begin
                h12v = h24 - 5'd12;
                pm   = 1'b1;
            end
            if (bin_mode)
                enc_hour = {pm, 2'b0, h12v};
            else
                enc_hour = {pm, 7'(u8_to_bcd({3'b0, h12v}) & 8'h7F)};
        end
    endfunction

    function automatic logic [4:0] dec_hour(
        input logic [7:0] raw,
        input logic bin_mode,
        input logic is_24h
    );
        logic [4:0] h;
        logic pm;
        if (is_24h) begin
            dec_hour = bin_mode ? raw[4:0] : bcd_to_u5_hour(raw);
        end else begin
            pm = raw[7];
            if (bin_mode) begin
                h = raw[5:0];
                if (h == 0 || h > 5'd12)
                    h = 5'd12;
            end else begin
                h = bcd_to_u5_hour(raw & 8'h7F);
                if (h > 5'd12)
                    h = 5'd12;
            end
            if (h == 12) begin
                if (pm)
                    dec_hour = 5'd12;
                else
                    dec_hour = 5'd0;
            end else begin
                if (pm)
                    dec_hour = h + 5'd12;
                else
                    dec_hour = h;
            end
        end
    endfunction

    function automatic logic [7:0] century_bcd_inc(input logic [7:0] b);
        logic [7:0] v;
        v = bcd_to_u8(b);
        if (v >= 8'd99)
            century_bcd_inc = 8'h0;
        else
            century_bcd_inc = u8_to_bcd(v + 1'b1);
    endfunction

    always_comb begin
        unique case (cmos_ram[10][3:0])
            4'd0: pie_reload_q = 24'd0;
            4'd1: pie_reload_q = 24'(CLK_HZ / 32768);
            4'd2: pie_reload_q = 24'(CLK_HZ / 16384);
            4'd3: pie_reload_q = 24'(CLK_HZ / 8192);
            4'd4: pie_reload_q = 24'(CLK_HZ / 4096);
            4'd5: pie_reload_q = 24'(CLK_HZ / 2048);
            4'd6: pie_reload_q = 24'(CLK_HZ / 1024);
            4'd7: pie_reload_q = 24'(CLK_HZ / 512);
            4'd8: pie_reload_q = 24'(CLK_HZ / 256);
            4'd9: pie_reload_q = 24'(CLK_HZ / 128);
            4'd10: pie_reload_q = 24'(CLK_HZ / 64);
            4'd11: pie_reload_q = 24'(CLK_HZ / 32);
            4'd12: pie_reload_q = 24'(CLK_HZ / 16);
            4'd13: pie_reload_q = 24'(CLK_HZ / 8);
            4'd14: pie_reload_q = 24'(CLK_HZ / 4);
            default: pie_reload_q = 24'(CLK_HZ / 2);
        endcase
    end

    function automatic logic alarm_field_ok(
        input logic [7:0] alarm_byte,
        input logic [7:0] time_byte
    );
        alarm_field_ok = alarm_byte[7] || (alarm_byte == time_byte);
    endfunction

    wire [7:0] enc_sec  = enc_sec_min(sec_bin, dm_bin);
    wire [7:0] enc_min  = enc_sec_min(min_bin, dm_bin);
    wire [7:0] enc_hourv = enc_hour(hour_bin, dm_bin, mode_24h);
    wire [7:0] enc_dom  = dm_bin ? {3'b0, dom_bin} : u8_to_bcd({3'b0, dom_bin});
    wire [7:0] enc_mon  = dm_bin ? {4'b0, month_bin} : u8_to_bcd({4'b0, month_bin});
    wire [7:0] enc_year = dm_bin ? year_bin : u8_to_bcd(year_bin);
    wire [7:0] enc_dow  = {5'b0, dow_bin};

    wire alarm_now = alarm_field_ok(cmos_ram[1], enc_sec)
        && alarm_field_ok(cmos_ram[3], enc_min)
        && alarm_field_ok(cmos_ram[5], enc_hourv);

    logic [6:0] rd_idx;
    always_comb begin
        o_d = 8'hFF;
        rd_idx = index_reg[6:0];
        if (rd) begin
            if (!i_a0)
                o_d = index_reg;
            else begin
                unique case (rd_idx)
                    7'h00: o_d = enc_sec;
                    7'h01: o_d = cmos_ram[1];
                    7'h02: o_d = enc_min;
                    7'h03: o_d = cmos_ram[3];
                    7'h04: o_d = enc_hourv;
                    7'h05: o_d = cmos_ram[5];
                    7'h06: o_d = enc_dow;
                    7'h07: o_d = enc_dom;
                    7'h08: o_d = enc_mon;
                    7'h09: o_d = enc_year;
                    7'h0A: o_d = {uip_phase, cmos_ram[10][6:0]};
                    7'h0B: o_d = cmos_ram[11];
                    7'h0C: o_d = {reg_c_irqf, reg_c_pf, reg_c_af, reg_c_uf, 4'b0};
                    7'h0D: o_d = 8'h80;
                    default: o_d = cmos_ram[rd_idx];
                endcase
            end
        end
    end

    assign o_rtc_irq = reg_c_irqf;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            index_reg <= '0;
            for (int i = 0; i < 128; i++)
                cmos_ram[i] <= 8'h00;
            sec_bin   <= 6'd0;
            min_bin   <= 6'd0;
            hour_bin  <= 5'd0;
            dow_bin   <= 3'd2;
            dom_bin   <= 5'd6;
            month_bin <= 4'd10;
            year_bin  <= 8'd97;
            sub_sec   <= '0;
            uip_phase <= 1'b0;
            reg_c_pf   <= 1'b0;
            reg_c_af   <= 1'b0;
            reg_c_uf   <= 1'b0;
            reg_c_irqf <= 1'b0;
            pie_div    <= '0;
            alarm_match_d <= 1'b0;
            read_c_d1  <= 1'b0;
            cmos_ram[10] <= 8'h26;
            cmos_ram[11] <= 8'h02;
            cmos_ram[50] <= 8'h19;
        end else begin
            alarm_match_d <= alarm_now;

            if (read_c_d1) begin
                reg_c_pf   <= 1'b0;
                reg_c_af   <= 1'b0;
                reg_c_uf   <= 1'b0;
                reg_c_irqf <= 1'b0;
            end else begin

            if (wr) begin
                    if (!i_a0)
                        index_reg <= i_d;
                    else begin
                        unique case (index_reg[6:0])
                            7'h00: sec_bin <= dm_bin ? i_d[5:0] : bcd_to_u6(i_d);
                            7'h02: min_bin <= dm_bin ? i_d[5:0] : bcd_to_u6(i_d);
                            7'h04: hour_bin <= dec_hour(i_d, dm_bin, mode_24h);
                            7'h06: dow_bin <= i_d[2:0];
                            7'h07: begin
                                logic [7:0] dom_u8;
                                dom_u8 = bcd_to_u8(i_d);
                                dom_bin <= dm_bin ? i_d[4:0] : dom_u8[4:0];
                            end
                            7'h08: begin
                                logic [7:0] mon_u8;
                                mon_u8 = bcd_to_u8(i_d);
                                month_bin <= dm_bin ? i_d[3:0] : mon_u8[3:0];
                            end
                            7'h09: year_bin <= dm_bin ? (i_d > 8'd99 ? 8'd99 : i_d)
                                : bcd_to_u8(i_d);
                            7'h01, 7'h03, 7'h05: cmos_ram[index_reg[6:0]] <= i_d;
                            7'h0A: cmos_ram[10] <= i_d & 8'h7F;
                            7'h0B: cmos_ram[11] <= i_d;
                            7'h32: cmos_ram[50] <= i_d;
                            7'h0C, 7'h0D: ;
                            default: cmos_ram[index_reg[6:0]] <= i_d;
                        endcase
                    end
                end

            if (!set_stop) begin
                    if (sub_sec < SUB_LAST) begin
                        sub_sec <= sub_sec + 1'b1;
                        uip_phase <= ((sub_sec + 1'b1) >= UIP_START);
                    end else begin
                        sub_sec   <= '0;
                        uip_phase <= 1'b0;
                        // 秒进位链
                        if (sec_bin != 6'd59)
                            sec_bin <= sec_bin + 1'b1;
                        else begin
                            sec_bin <= 6'd0;
                            if (min_bin != 6'd59)
                                min_bin <= min_bin + 1'b1;
                            else begin
                                min_bin <= 6'd0;
                                if (hour_bin != 5'd23)
                                    hour_bin <= hour_bin + 1'b1;
                                else begin
                                    hour_bin <= 5'd0;
                                    if (dow_bin == 3'd7)
                                        dow_bin <= 3'd1;
                                    else
                                        dow_bin <= dow_bin + 1'b1;
                                    begin
                                        int fy, dmax;
                                        fy = full_year(cmos_ram[50], year_bin);
                                        dmax = dim(month_bin, fy);
                                        if (dom_bin == dmax) begin
                                            dom_bin <= 5'd1;
                                            if (month_bin == 4'd12) begin
                                                month_bin <= 4'd1;
                                                if (year_bin == 8'd99) begin
                                                    year_bin <= 8'd0;
                                                    cmos_ram[50] <= century_bcd_inc(cmos_ram[50]);
                                                end else
                                                    year_bin <= year_bin + 1'b1;
                                            end else
                                                month_bin <= month_bin + 1'b1;
                                        end else
                                            dom_bin <= dom_bin + 1'b1;
                                    end
                                end
                            end
                        end
                        if (uie_en) begin
                            reg_c_uf   <= 1'b1;
                            reg_c_irqf <= 1'b1;
                        end
                    end
                end

            if (pie_en && pie_reload_q > 0) begin
                    if (pie_div >= pie_reload_q - 1) begin
                        pie_div <= '0;
                        reg_c_pf <= 1'b1;
                        reg_c_irqf <= 1'b1;
                    end else
                        pie_div <= pie_div + 1'b1;
                end

            if (aie_en && alarm_now && !alarm_match_d) begin
                reg_c_af   <= 1'b1;
                reg_c_irqf <= 1'b1;
            end

            end // else !read_c_d1

            read_c_d1 <= read_c_pulse;
        end
    end

endmodule
