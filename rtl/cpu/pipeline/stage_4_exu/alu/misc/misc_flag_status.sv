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
//  File        : misc_flag_status.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_flag_status module
// ============================================================================

`include "openx86_defs.h.sv"

module misc_flag_status (    input  logic [31: 0]  flags_in,  // 输入标志
    input  logic [ 5: 0]   op, // 标志类微操作
    output logic [31: 0] flags_out // 输出标志
);
    // 组合逻辑：推导输出
    always_comb begin
        flags_out = flags_in;
        // CLC/STC/CMC/CLD/STD/CLI/STI：按位改写 FLAGS
        unique case (op)
            `EXE_INT_CLC: flags_out = { flags_in[31:  1], 1'b0 };
            `EXE_INT_STC: flags_out = { flags_in[31:  1], 1'b1 };
            `EXE_INT_CMC: flags_out = { flags_in[31:  1], ~flags_in[0] };
            `EXE_INT_CLD: flags_out = { flags_in[31: 11], 1'b0, flags_in[ 9: 0] };
            `EXE_INT_STD: flags_out = { flags_in[31: 11], 1'b1, flags_in[ 9: 0] };
            `EXE_INT_CLI: flags_out = { flags_in[31: 10], 1'b0, flags_in[ 8: 0] };
            `EXE_INT_STI: flags_out = { flags_in[31: 10], 1'b1, flags_in[ 8: 0] };
            default: ;
        endcase
    end
endmodule
