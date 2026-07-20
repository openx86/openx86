// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : pipeline_reg_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : exu_result_mux smoke test (stage 5 EXU infrastructure)
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module pipeline_reg_tb;

    exu_dispatch_out_t entries [0: 47];
    exu_dispatch_out_t selected;
    logic [ 5: 0]      select_idx;

    assign entries[0].data.result     = 32'h11111111;
    assign entries[0].write_gpr     = 1'b1;
    assign entries[0].write_flags   = 1'b0;
    assign entries[1].data.result     = 32'h22222222;
    assign entries[1].write_gpr     = 1'b1;
    assign entries[1].write_flags   = 1'b1;

    exu_result_mux #(
        .LP_ENTRIES (48)
    ) u_dut (
        .i_entries  (entries),
        .i_select   (select_idx),
        .o_selected (selected)
    );

    initial begin
        select_idx = 6'd0;
        #1;
        if (selected.data.result !== 32'h11111111) begin
            $display("pipeline_reg_tb: FAIL select 0");
            $finish(1);
        end
        select_idx = 6'd1;
        #1;
        if (selected.data.result !== 32'h22222222) begin
            $display("pipeline_reg_tb: FAIL select 1");
            $finish(1);
        end
        if (~selected.write_flags) begin
            $display("pipeline_reg_tb: FAIL flags bit");
            $finish(1);
        end
        $display("PASS pipeline_reg");
        $finish(0);
    end

endmodule
