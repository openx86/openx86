/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_8259_pic.
*/
// ============================================================================
// Intel 8259 PIC — 单片简化模型（可级联）
// 主机接口：ISA 式 nCS/nRD/nWR + A0（0=命令/OCW，1=数据/IMR）
// 片选与端口译码由 bus_controller / 总线侧完成（主片 0x20/0x21，从片 0xA0/0xA1）
// 支持 ICW1–ICW4 初始化、OCW1 写 IMR、OCW2 非特殊 EOI(0x20)
// 读命令口: IRR（简化，不区分 ISR/IRR 选择）
// o_intr = |(i_ir & ~imr)（电平敏感，与边沿触发真片有差异）
// ============================================================================

module chip_8259_pic (
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic        i_a0,
    input  logic [ 7: 0]  i_d,
    output logic [ 7: 0]  o_d,
    input  logic [ 7: 0]  i_ir,
    output logic        o_intr,
    input  logic        reset_n,
    input  logic        clock
);

    typedef enum logic [ 2: 0] {
        ST_RESET,
        ST_ICW2,
        ST_ICW3,
        ST_ICW4,
        ST_READY
    } pic_state_e;

    pic_state_e           state;
    logic                 need_icw3;
    logic                 need_icw4;
    logic [ 7: 0]           icw1;
    logic [ 7: 0]           icw2_vec;
    logic [ 7: 0]           icw3;
    logic [ 7: 0]           icw4;
    logic [ 7: 0]           imr;
    logic [ 7: 0]           irr;
    logic [ 7: 0]           isr;

    logic wr = !i_cs_n && !i_wr_n;
    logic rd = !i_cs_n && !i_rd_n;

    assign o_intr = (state == ST_READY) && (|(i_ir & ~imr));

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            state     <= ST_RESET;
            need_icw3 <= 1'b0;
            need_icw4 <= 1'b0;
            icw1      <= '0;
            icw2_vec  <= '0;
            icw3      <= '0;
            icw4      <= '0;
            imr       <= 8'hFF;
            irr       <= '0;
            isr       <= '0;
        end else if (wr) begin
            if (i_a0 == 1'b0) begin
                if (i_d[4]) begin
                    icw1      <= i_d;
                    need_icw3 <= !i_d[1];
                    need_icw4 <= i_d[0];
                    state     <= ST_ICW2;
                end else if (state == ST_READY) begin
                    if (i_d == 8'h20) begin
                        isr <= '0;
                    end
                end
            end else begin
                unique case (state)
                    ST_RESET: ;
                    ST_ICW2: begin
                        icw2_vec <= i_d;
                        if (need_icw3)
                            state <= ST_ICW3;
                        else if (need_icw4)
                            state <= ST_ICW4;
                        else
                            state <= ST_READY;
                    end
                    ST_ICW3: begin
                        icw3 <= i_d;
                        if (need_icw4)
                            state <= ST_ICW4;
                        else
                            state <= ST_READY;
                    end
                    ST_ICW4: begin
                        icw4  <= i_d;
                        state <= ST_READY;
                    end
                    ST_READY: begin
                        imr <= i_d;
                    end
                endcase
            end
        end else begin
            irr <= i_ir & ~imr;
        end
    end

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (i_a0 == 1'b0)
                o_d = irr;
            else
                o_d = imr;
        end
    end

endmodule
