/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_i8042_ps2.
*/
// ============================================================================
// Intel 8042 键盘控制器 — 键盘 + PS/2 鼠标（AUX）
// 0x60: 数据口（读输出缓冲 / 写发往当前端口）
// 0x64: 状态(读) / 命令(写)
//
// USE_REAL_PS2=1：双 rtl/peripheral/ps2/ps2_host_phy，开漏引脚 + 片外上拉（经 5V 容忍电平转换）
// USE_REAL_PS2=0：保留 i_*_push 仿真注入，引脚输出为空闲高阻模型
// ============================================================================

module chip_i8042_ps2 #(
    parameter bit  USE_REAL_PS2 = 1'b0,
    parameter int CLK_HZ       = 50_000_000
) (
    input logic          i_cs_n,    input logic          i_rd_n,    input logic          i_wr_n,    input logic          i_a0,    input logic [ 7: 0]  i_d,    // 0 = 数据口 0x60，1 = 状态/命令 0x64
    output logic [ 7: 0] o_d,    input logic          i_kbd_push,    input logic [ 7: 0]  i_kbd_data,    input logic          i_aux_push,    input logic [ 7: 0]  i_aux_data,    output logic         o_kbd_irq,    output logic         o_aux_irq,    output logic         o_ps2_kbd_clk_out,    output logic         o_ps2_kbd_clk_oe,    input logic          i_ps2_kbd_clk_in,    output logic         o_ps2_kbd_dat_out,    output logic         o_ps2_kbd_dat_oe,    input logic          i_ps2_kbd_dat_in,    output logic         o_ps2_aux_clk_out,    output logic         o_ps2_aux_clk_oe,    input logic          i_ps2_aux_clk_in,    output logic         o_ps2_aux_dat_out,    output logic         o_ps2_aux_dat_oe,    input logic          i_ps2_aux_dat_in,    input logic          clock,    input logic          reset_n);

    logic wr = !i_cs_n && !i_wr_n;
    logic rd = !i_cs_n && !i_rd_n;

    localparam int KBD_D = 16;
    localparam int AUX_D = 16;

    logic [ 7: 0] kbd_fifo [0:KBD_D-1];
    logic [ 7: 0] aux_fifo [0:AUX_D-1];
    logic [ 3: 0] kbd_wptr, kbd_rptr, kbd_count;
    logic [ 3: 0] aux_wptr, aux_rptr, aux_count;
    logic       use_aux_out;

    logic kbd_obf = (kbd_count != 4'h0);
    logic aux_obf = (aux_count != 4'h0);

    logic kbd_if_en;
    logic aux_if_en;
    logic kbd_irq_en;
    logic aux_irq_en;
    logic next_wr_to_aux;
    logic kbd_parity_err;
    logic aux_parity_err;

    logic        kbd_tx_req;
    logic [ 7: 0]  kbd_tx_byte;
    logic        kbd_tx_busy;
    logic        kbd_rx_str;
    logic [ 7: 0]  kbd_rx_dat;
    logic        kbd_rx_err;
    logic        kbd_tx_done;
    logic        kbd_tx_err;

    logic        aux_tx_req;
    logic [ 7: 0]  aux_tx_byte;
    logic        aux_tx_busy;
    logic        aux_rx_str;
    logic [ 7: 0]  aux_rx_dat;
    logic        aux_rx_err;
    logic        aux_tx_done;
    logic        aux_tx_err;

    logic        kbd_tx_pending;
    logic [ 7: 0]  kbd_tx_hold;
    logic        aux_tx_pending;
    logic [ 7: 0]  aux_tx_hold;
    logic        rd_data_port_d;

    logic obf_stat = use_aux_out ? aux_obf : kbd_obf;
    logic ibf_stat = kbd_tx_pending | aux_tx_pending;
    logic [ 7: 0] kbd_head = kbd_fifo[kbd_rptr];
    logic [ 7: 0] aux_head = aux_fifo[aux_rptr];

    assign o_kbd_irq = kbd_if_en && kbd_irq_en && kbd_obf;
    assign o_aux_irq = aux_if_en && aux_irq_en && aux_obf;

    logic [ 7: 0] status_rd = {
        1'b0,
        aux_obf,
        1'b0,
        1'b0,
        kbd_parity_err | aux_parity_err,
        kbd_parity_err | aux_parity_err,
        ibf_stat,
        obf_stat
    };

    generate
        if (USE_REAL_PS2) begin : g_phy
            ps2_host_phy #(
                .CLK_HZ ( CLK_HZ )
            ) u_kbd_phy (
                .clock       ( clock ),
                .reset_n       ( reset_n ),
                .i_ps2_clk_in  ( i_ps2_kbd_clk_in ),
                .i_ps2_dat_in  ( i_ps2_kbd_dat_in ),
                .o_ps2_clk_out ( o_ps2_kbd_clk_out ),
                .o_ps2_clk_oe  ( o_ps2_kbd_clk_oe ),
                .o_ps2_dat_out ( o_ps2_kbd_dat_out ),
                .o_ps2_dat_oe  ( o_ps2_kbd_dat_oe ),
                .i_tx_req      ( kbd_tx_req ),
                .i_tx_byte     ( kbd_tx_byte ),
                .o_tx_busy     ( kbd_tx_busy ),
                .o_tx_done     ( kbd_tx_done ),
                .o_tx_err      ( kbd_tx_err ),
                .o_rx_strobe   ( kbd_rx_str ),
                .o_rx_byte     ( kbd_rx_dat ),
                .o_rx_err      ( kbd_rx_err )
            );

            ps2_host_phy #(
                .CLK_HZ ( CLK_HZ )
            ) u_aux_phy (
                .clock       ( clock ),
                .reset_n       ( reset_n ),
                .i_ps2_clk_in  ( i_ps2_aux_clk_in ),
                .i_ps2_dat_in  ( i_ps2_aux_dat_in ),
                .o_ps2_clk_out ( o_ps2_aux_clk_out ),
                .o_ps2_clk_oe  ( o_ps2_aux_clk_oe ),
                .o_ps2_dat_out ( o_ps2_aux_dat_out ),
                .o_ps2_dat_oe  ( o_ps2_aux_dat_oe ),
                .i_tx_req      ( aux_tx_req ),
                .i_tx_byte     ( aux_tx_byte ),
                .o_tx_busy     ( aux_tx_busy ),
                .o_tx_done     ( aux_tx_done ),
                .o_tx_err      ( aux_tx_err ),
                .o_rx_strobe   ( aux_rx_str ),
                .o_rx_byte     ( aux_rx_dat ),
                .o_rx_err      ( aux_rx_err )
            );
        end else begin : g_no_phy
            assign kbd_tx_busy = 1'b0;
            assign kbd_tx_done = 1'b0;
            assign kbd_tx_err  = 1'b0;
            assign kbd_rx_str  = 1'b0;
            assign kbd_rx_dat  = '0;
            assign kbd_rx_err  = 1'b0;
            assign aux_tx_busy = 1'b0;
            assign aux_tx_done = 1'b0;
            assign aux_tx_err  = 1'b0;
            assign aux_rx_str  = 1'b0;
            assign aux_rx_dat  = '0;
            assign aux_rx_err  = 1'b0;
            assign o_ps2_kbd_clk_out = 1'b1;
            assign o_ps2_kbd_clk_oe  = 1'b0;
            assign o_ps2_kbd_dat_out = 1'b1;
            assign o_ps2_kbd_dat_oe  = 1'b0;
            assign o_ps2_aux_clk_out = 1'b1;
            assign o_ps2_aux_clk_oe  = 1'b0;
            assign o_ps2_aux_dat_out = 1'b1;
            assign o_ps2_aux_dat_oe  = 1'b0;
        end
    endgenerate

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            kbd_wptr       <= '0;
            kbd_rptr       <= '0;
            kbd_count      <= '0;
            aux_wptr       <= '0;
            aux_rptr       <= '0;
            aux_count      <= '0;
            use_aux_out    <= 1'b0;
            kbd_if_en      <= 1'b1;
            aux_if_en      <= 1'b1;
            kbd_irq_en     <= 1'b1;
            aux_irq_en     <= 1'b1;
            next_wr_to_aux <= 1'b0;
            kbd_parity_err <= 1'b0;
            aux_parity_err <= 1'b0;
            kbd_tx_req     <= 1'b0;
            aux_tx_req     <= 1'b0;
            kbd_tx_byte    <= '0;
            aux_tx_byte    <= '0;
            kbd_tx_pending <= 1'b0;
            kbd_tx_hold    <= '0;
            aux_tx_pending <= 1'b0;
            aux_tx_hold    <= '0;
            rd_data_port_d <= 1'b0;
        end else begin
            kbd_tx_req <= 1'b0;
            aux_tx_req <= 1'b0;

            if (USE_REAL_PS2 && kbd_rx_str && (kbd_count < KBD_D)) begin
                kbd_fifo[kbd_wptr] <= kbd_rx_dat;
                kbd_wptr           <= kbd_wptr + 4'h1;
                kbd_count          <= kbd_count + 4'h1;
            end
            if (USE_REAL_PS2 && kbd_rx_err)
                kbd_parity_err <= 1'b1;

            if (USE_REAL_PS2 && aux_rx_str && (aux_count < AUX_D)) begin
                aux_fifo[aux_wptr] <= aux_rx_dat;
                aux_wptr           <= aux_wptr + 4'h1;
                aux_count          <= aux_count + 4'h1;
            end
            if (USE_REAL_PS2 && aux_rx_err)
                aux_parity_err <= 1'b1;

            if (i_kbd_push && (kbd_count < KBD_D)) begin
                kbd_fifo[kbd_wptr] <= i_kbd_data;
                kbd_wptr           <= kbd_wptr + 4'h1;
                kbd_count          <= kbd_count + 4'h1;
            end
            if (i_aux_push && (aux_count < AUX_D)) begin
                aux_fifo[aux_wptr] <= i_aux_data;
                aux_wptr           <= aux_wptr + 4'h1;
                aux_count          <= aux_count + 4'h1;
            end

            if (wr && i_a0) begin
                unique case (i_d)
                    8'hD4: next_wr_to_aux <= 1'b1;
                    8'hD3, 8'hD2: next_wr_to_aux <= 1'b0;
                    8'hAE: kbd_if_en <= 1'b1;
                    8'hAD: kbd_if_en <= 1'b0;
                    8'hA7: aux_if_en <= 1'b1;
                    8'hA8: aux_if_en <= 1'b0;
                    default: ;
                endcase
                if (i_d == 8'hD4)
                    use_aux_out <= 1'b1;
                else if (i_d == 8'hD3 || i_d == 8'hD2)
                    use_aux_out <= 1'b0;
            end

            if (wr && !i_a0) begin
                if (USE_REAL_PS2) begin
                    if (next_wr_to_aux && aux_if_en) begin
                        if (!aux_tx_busy && !aux_tx_pending) begin
                            aux_tx_req  <= 1'b1;
                            aux_tx_byte <= i_d;
                        end else if (!aux_tx_pending) begin
                            aux_tx_pending <= 1'b1;
                            aux_tx_hold    <= i_d;
                        end
                    end else if (kbd_if_en) begin
                        if (!kbd_tx_busy && !kbd_tx_pending) begin
                            kbd_tx_req  <= 1'b1;
                            kbd_tx_byte <= i_d;
                        end else if (!kbd_tx_pending) begin
                            kbd_tx_pending <= 1'b1;
                            kbd_tx_hold    <= i_d;
                        end
                    end
                end
                next_wr_to_aux <= 1'b0;
            end

            if (USE_REAL_PS2 && kbd_tx_done && kbd_tx_pending) begin
                kbd_tx_req     <= 1'b1;
                kbd_tx_byte    <= kbd_tx_hold;
                kbd_tx_pending <= 1'b0;
            end
            if (USE_REAL_PS2 && kbd_tx_err)
                kbd_tx_pending <= 1'b0;

            if (USE_REAL_PS2 && aux_tx_done && aux_tx_pending) begin
                aux_tx_req     <= 1'b1;
                aux_tx_byte    <= aux_tx_hold;
                aux_tx_pending <= 1'b0;
            end
            if (USE_REAL_PS2 && aux_tx_err)
                aux_tx_pending <= 1'b0;

            if (rd_data_port_d && !(rd && !i_a0)) begin
                if (use_aux_out && aux_obf) begin
                    aux_rptr  <= aux_rptr + 4'h1;
                    aux_count <= aux_count - 4'h1;
                end else if (!use_aux_out && kbd_obf) begin
                    kbd_rptr  <= kbd_rptr + 4'h1;
                    kbd_count <= kbd_count - 4'h1;
                end
            end

            rd_data_port_d <= (rd && !i_a0);

        end
    end

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (!i_a0) begin
                if (use_aux_out && aux_obf)
                    o_d = aux_head;
                else if (kbd_obf)
                    o_d = kbd_head;
                else
                    o_d = 8'h00;
            end else
                o_d = status_rd;
        end
    end

endmodule
