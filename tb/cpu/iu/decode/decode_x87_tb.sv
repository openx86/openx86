/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements decode_x87_tb.
*/
// ============================================================================
// decode_x87_esc 冒烟：D8 C1 = FADD ST0,ST1（mod=11 reg=000 rm=001）
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module decode_x87_tb;

    logic [ 7: 0] b0, b1;
    logic esc;
    logic [31: 0] mask;

    x87_esc dut (
        .i_b0             ( b0 ),
        .i_b1             ( b1 ),
        .o_is_esc         ( esc ),
        .o_mod            ( ),
        .o_reg            ( ),
        .o_rm             ( ),
        .o_esc_group      ( ),
        .o_opmask         ( mask ),
        .o_modrm_required ( ),
        .o_memory_operand ( )
    );

    initial begin
        b0 = 8'hD8;
        b1 = 8'hC1;
        #1;
        if (!esc || !mask[`X87_MASK_M_FADD_ST0_STI]) begin
            $display("FAIL D8 C1");
            $finish(1);
        end
        b0 = 8'h0F;
        b1 = 8'hA2;
        #1;
        if (esc) begin
            $display("FAIL non-ESC");
            $finish(1);
        end
        $display("decode_x87_tb PASS");
        $finish;
    end

endmodule
